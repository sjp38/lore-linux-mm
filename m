Message-ID: <3800B13E.655140FE@colorfullife.com>
Date: Sun, 10 Oct 1999 17:31:10 +0200
From: Manfred Spraul <manfreds@colorfullife.com>
MIME-Version: 1.0
Subject: execve-question
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

what happens / should happen if I call execve() in a multi-threaded
application?

I don't see that the mm structure is copied, and obviously noone
acquires the mm->mmap_sem.

--
	Manfred
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
