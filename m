From: Mark_H_Johnson.RTS@raytheon.com
Message-ID: <852568D5.006DBD55.00@raylex-gh01.eo.ray.com>
Date: Thu, 4 May 2000 14:53:24 -0500
Subject: Re: Updates to /bin/bash
Mime-Version: 1.0
Content-type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, quintela@fi.udc.es, trond.myklebust@fys.uio.no
List-ID: <linux-mm.kvack.org>


On this issue [updates to active files...] how does the typical distribution
update process handle this? For example, if I'm doing a package update using a
typical tool [gnoRPM, kpackage, etc.] what is happening behind the scenes to
prevent disaster? The situation where I've booted from CD-ROM & doing a major
distribution update would be safe doing a simple replacement. OTOH, if I get an
"urgent" patch that I need to apply, must I track down all the jobs that are
currently using the files being updated, get them stopped, do the update, and
then restart them to be "safe"? [and I'll quit doing the "dangerous" updates
that I've been doing through ignorance] If so, is that going to kill the use of
Linux in high availability situations [or must I run redundant systems to work
around this]?

The alternative I've seen in other OS's is to retain the old file "hidden" on
the file system [old inode]. All new references go to the new copy [new inode],
all old references refer to the hidden one [old inode]. When the [old inode]
reference count goes to zero, the hidden one is finally deleted. If the volume
is improperly dismounted [e.g., system crash] prior to the last user getting
done, the fsck done at reboot does the cleanup instead.
--Mark H Johnson
  <mailto:Mark_H_Johnson@raytheon.com>


|--------+----------------------->
|        |          Andrea       |
|        |          Arcangeli    |
|        |          <andrea@suse.|
|        |          de>          |
|        |                       |
|        |          05/04/00     |
|        |          01:43 PM     |
|        |                       |
|--------+----------------------->
  >----------------------------------------------------------------------------|
  |                                                                            |
  |       To:     Trond Myklebust <trond.myklebust@fys.uio.no>                 |
  |       cc:     "Juan J. Quintela" <quintela@fi.udc.es>, linux-mm@kvack.org, |
  |       linux-kernel@vger.rutgers.edu, (bcc: Mark H Johnson/RTS/Raytheon/US) |
  |       Subject:     Re: classzone-VM + mapped pages out of lru_cache        |
  >----------------------------------------------------------------------------|



On 4 May 2000, Trond Myklebust wrote:

>Not good. If I'm running /bin/bash, and somebody on the server updates
>/bin/bash, then I don't want to reboot my machine. With the above

If you use rename(2) to update the shell (as you should since `cp` would
corrupt also users that are reading /bin/bash from local fs) then nfs
should get it right also with my patch since it should notice the inode
number changed (the nfs fd handle should get the inode number as cookie),
right?
[snip]




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
