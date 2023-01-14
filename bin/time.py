#!/usr/bin/env python3
#
# This script spins up a webserver which returns the time from the /time endpoint.
# I wrote this so that getting the time from the Vagrant VM can be done in well 
# under a second, which means the docker-check-time-offset alias will be more accurate.
#


from datetime import datetime
import web


urls = (
    '/', 'hello',
    '/time', 'time'
)

#
# Endpoint for /
#
class hello:

    def GET(self):
        return("Please hit the /time endpoint instead.\n")


#
# Endpoint for /time
#
class time:

    def GET(self):
        now = datetime.utcnow(); 
        retval = now.strftime("%Y%m%dT%H%M%SZ\n") 
        return(retval);



if __name__ == "__main__":
    app = web.application(urls, globals())
    app.run()

