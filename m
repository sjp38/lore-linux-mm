Received: from mail.ccr.net (eric@alogconduit1am.ccr.net [208.130.159.13])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA03083
	for <linux-mm@kvack.org>; Sun, 3 Jan 1999 17:00:35 -0500
Subject: Bug in the mmap code?
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 03 Jan 1999 16:00:57 -0600
Message-ID: <m13e5skodi.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


I have just been looking through the mmap code, 
with emphases on generic_file_mmap.

What I have discovered is that generic_file_mmap increases file->f_count
but nothing decreases said count.

file->f_count is also increased if a vma is split in half, by an unmap 
operation by the generic code.

Should the generic code handle this or should we leave all of that
work to the open and close methods?

Eric


--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
