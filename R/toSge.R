#' @title ToSge
#'
#' @description SGR parser for R
#' @param cores Cores to use
#' @param name Name of the job
#' @param queue Queue where to run the script. choose one of the follow possibilities: 'imppc', 'imppc12', 'imppcv3'
#' @param log Full path of log file, the name of the file will be the date + name of the job
#' @param venv Name of python virtual environment if it is necessary
#' @param script Full path of script to run
#' @param memmory Amount of RAM GB
#' @param email Email where to send notifications
#' @export
#'
#' @examples
#' \dontrun{
#' cores = '16'
#' name = 'mapInsu'
#' queue = 'imppcv3'
#' log = '/imppc/labs/lplab/share/marc/insulinomas/logs'
#' script = '/imppc/labs/lplab/share/marc/bin/Strelka.sh'
#' memmory = '8'
#' email = 'clusterigtpmsubirana@gmail.com'
#' toSge(cores=cores,
#'       name=name,
#'       queue=queue,
#'       log=log,
#'       venv=venv,
#'       script=script,
#'       memmory=memmory,
#'       email=email)
#'
#' toSge()

toSge <- function(cores=NULL,
                  name=NULL,
                  queue='imppc',
                  log=NULL,
                  venv=NULL,
                  script=NULL,
                  memmory=NULL,
                  email=NULL,
                  source=NULL) {
  # import packages
  #install.packages("glue")
  fileName = paste0(Sys.Date(), "_", name, ".log")
  log = file.path(log, fileName)
  library('glue')

  # define tmp file for running in SGE
  cmd <- glue('#!/bin/bash\n',
              '# request Bourne shell as shell for job\n',
              '#$ -S /bin/bash\n',
              '# Name for the script in the queuing system\n',
              '#$ -N {name}\n',
              '# name of the queue you want to use\n',
              '#$ -q {queue}\n',
              '#$ -e {log}\n',
              '# You can redirect the output to a specific file\n',
              '#$ -o {log}\n',
              '# In order to receive an e-mail at the begin of the execution and in the end\n',
              '#$ -m be\n',
              '# You have to specify an addrehold_jidss\n',
              '#$ -M {email}\n')

  write(cmd, file='/imppc/labs/lplab/share/tmpSge/tmpToSge.sh')

  if (!is.null(cores)) {
    cmd <- glue('#$ -pe smp {cores}\n')
    write(cmd,
          file='/imppc/labs/lplab/share/tmpSge/tmpToSge.sh',
          append = TRUE)
  }

  if (!is.null(memmory)) {
    cmd <- glue('#$ -l h_vmem={memmory}\n')
    write(cmd,
          file='/imppc/labs/lplab/share/tmpSge/tmpToSge.sh',
          append = TRUE)
  }


  cmd <- '\n#Actual work\n'

  write(cmd,
        file='/imppc/labs/lplab/share/tmpSge/tmpToSge.sh',
        append = TRUE)


  if (!is.null(venv)) {
    venv = glue('/imppc/labs/lplab/share/env/{venv}/bin/python')
    cmd <- glue('{venv} -u {script}')
    write(cmd,
          file='/imppc/labs/lplab/share/tmpSge/tmpToSge.sh',
          append = TRUE)
  } else {
    cmd <- glue('{script}\n')
    write(cmd,
          file='/imppc/labs/lplab/share/tmpSge/tmpToSge.sh',
          append = TRUE)
  }

  # run command
  cmd = 'qsub /imppc/labs/lplab/share/tmpSge/tmpToSge.sh'
  system(cmd)

}




