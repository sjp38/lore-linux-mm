From: Mark_H_Johnson.RTS@raytheon.com
Message-ID: <852568D6.004A028D.00@raylex-gh01.eo.ray.com>
Date: Fri, 5 May 2000 08:32:46 -0500
Subject: Re: Updates to /bin/bash
Mime-Version: 1.0
Content-type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: trond.myklebust@fys.uio.no
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, linuxguy@directlink.net
List-ID: <linux-mm.kvack.org>


Just to recap & make sure I have this straight.

 (1) IF I'm dealing with local files & do NOT have the area NFS mounted, then
the typical methods of updating files is OK.

 (2) IF I'm dealing with NFS mounted files, all bets are off. Please confirm
that I should take some action (e.g., remount the volume) to make sure the state
is purged after the updates are made.

I can see that how the second situation works has an impact on diskless (or
small disk) workstations [seems to cause lots of administrative headaches that I
would like to avoid]. I'm in the middle of planning the deployment of a few
clustered systems (head node w/ up to 40 compute nodes) as well as 100-200
workstations for development. If I understand this right, I should spend a
little more money to put bigger disks on each machine & have most of the OS and
tools hosted on each machine. Then use rdist or similar method to keep the
machines updated. Restrict the use of NFS mounting (with appropriate controls)
for the items I just "have to share". [this may also explain why we've had
problems on our currently deployed systems using NFS... Hmm.]

Thanks for the explanations.
--Mark H Johnson
  <mailto:Mark_H_Johnson@raytheon.com>


|--------+---------------------------->
|        |          Trond Myklebust   |
|        |          <trond.myklebust@f|
|        |          ys.uio.no>        |
|        |                            |
|        |          05/05/00 02:14 AM |
|        |          Please respond to |
|        |          trond.myklebust   |
|        |                            |
|--------+---------------------------->
  >----------------------------------------------------------------------------|
  |                                                                            |
  |       To:     Matthew Vanecek <linuxguy@directlink.net>                    |
  |       cc:     linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, (bcc: Mark|
  |       H Johnson/RTS/Raytheon/US)                                           |
  |       Subject:     Re: Updates to /bin/bash                                |
  >----------------------------------------------------------------------------|



>>>>> " " == Matthew Vanecek <linuxguy@directlink.net> writes:

    >> On 4 May 2000, Trond Myklebust wrote:
    >>
    >> >Not good. If I'm running /bin/bash, and somebody on the server
    >> >updates /bin/bash, then I don't want to reboot my
    >> >machine. With the above
    >>

     > You wouldn't have to reboot.  Why would you think you need to
     > reboot?  This isn't Winbloze, for god's sake.  All it means is
     > that new bash processes will use the updated version, while old
     > processes would still be using the old version--it's loaded in

NO. This behaviour is exactly what Andreas patch would break. New
processes would get a mixture of old and new versions because the page
cache itself would be out of sync.

     > memory, remember?  Hell, you can even overwrite the libc on a
     > running system.

That is only true of files on local storage. We are discussing NFS,
which is a stateless file system.

Cheers,
  Trond
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
