From: Wolfgang Wander <wwc@rentec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <17033.14096.441537.200132@gargle.gargle.HOWL>
Date: Mon, 16 May 2005 20:13:04 -0400
Subject: Re: 2.6.12-rc4-mm2
In-Reply-To: <20050516163900.6daedc40.akpm@osdl.org>
References: <20050516130048.6f6947c1.akpm@osdl.org>
	<20050516210655.E634@flint.arm.linux.org.uk>
	<030401c55a6e$34e67cb0$0f01a8c0@max>
	<20050516163900.6daedc40.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Richard Purdie <rpurdie@rpsys.net>, rmk@arm.linux.org.uk, Wolfgang Wander <wwc@rentec.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Thanks Richard for the debugging.

Can you try the following patch that fixes a stupid typo of mine:

Signed-off-by: Wolfgang Wander <wwc@rentec.com>

--- linux-2.6.12-rc4-wwc/arch/arm/mm/mmap.c~    2005-05-10 16:33:34.000000000 -0400
+++ linux-2.6.12-rc4-wwc/arch/arm/mm/mmap.c     2005-05-16 20:10:05.000000000 -0400
@@ -76,7 +76,7 @@ arch_get_unmapped_area(struct file *filp
        if( len > mm->cached_hole_size )
                start_addr = addr = mm->free_area_cache;
        else {
-               start_addr = TASK_UNMAPPED_BASE;
+               start_addr = addr = TASK_UNMAPPED_BASE;
                mm->cached_hole_size = 0;
        }
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
