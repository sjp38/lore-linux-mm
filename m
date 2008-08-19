From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Tue, 19 Aug 2008 17:05:09 -0400
Message-Id: <20080819210509.27199.6626.sendpatchset@lts-notebook>
Subject: [Patch 0/6] Mlock:  doc, patch grouping and error return cleanups
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: riel@redhat.com, linux-mm <linux-mm@kvack.org>, kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

The six patches introduced by this message are against:

	2.6.27-rc3-mmotm-080819-0259

These patches replace the series of 5 RFC patches posted by Kosaki
Motohiro at:

	http://marc.info/?l=linux-mm&m=121843816412096&w=4


Patch 1/6 is a rework of Kosaki-san's cleanup of the __mlock_vma_pages_range()
comment block.  I tried to follow kerneldoc format.  Randy will tell me if
I made a mistake :)

Patch 2/6 is a rework of Kosaki-san's patch to remove the locked_vm 
adjustments for "special vmas" during mmap() processing.  Kosaki-san
wanted to "kill" this adjustment.  After discussion, he requested that
it be resubmitted as a separate patch.  This is the first step in providing
the separate patch [even tho' I consider this part of correctly "handling
mlocked pages during mmap()..."].

Patch 3/6 resubmits the locked_vm adjustment during mmap(MAP_LOCKED)) to
match the explicit mlock() behavior.

Patch 4/6 is Kosaki-san's patch to change the error return for mlock
when, after downgrading the mmap semaphore to read during population of
the vma and switching back to write lock as our callers expect, the 
vma that we just locked no longer covers the range we expected.  See
the description.

Patch 5/6 backs out a mainline patch to make_pages_present() to adjust
the error return to match the Posix specification for mlock error
returns.  make_pages_present() is used by other than mlock, so this
isn't really the appropriate place to make the change, even tho'
apparently only mlock() looks at the return value from make_pages_present().

Patch 6/6 fixes the mlock error return to be Posixly Correct in the
appropriate [IMO] paths in mlock.c.  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
