MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14610.29880.728540.947675@charged.uio.no>
Date: Fri, 5 May 2000 09:14:00 +0200 (CEST)
Subject: Re: Updates to /bin/bash
In-Reply-To: <39121254.F7F71DAC@directlink.net>
References: <852568D5.006DBD55.00@raylex-gh01.eo.ray.com>
	<39121254.F7F71DAC@directlink.net>
Reply-To: trond.myklebust@fys.uio.no
From: Trond Myklebust <trond.myklebust@fys.uio.no>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Vanecek <linuxguy@directlink.net>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

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
