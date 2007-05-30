Subject: numa_maps display of shmem--need/want '\040(deleted)' ???
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Content-Type: text/plain
Date: Wed, 30 May 2007 13:02:37 -0400
Message-Id: <1180544557.5850.78.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Christoph [,anyone?]:

While I'm looking at numa_maps, do we need/want that funky suffix string
that shows up on the file names of shmem regions in numa_maps?  I expect
it will show up on any unlinked, mmap'ed file, but haven't tested that
case.  Is it useful information in the context of numa_maps?

Maybe translate the '\040' back to a space?

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
