Received: from 192.168.0.43 ([192.168.0.52] (may be forged))
          by chpc.ict.ac.cn (2.5 Build 2639 (Berkeley 8.8.6)/8.8.4) with SMTP
	  id JAA00043 for <linux-mm@kvack.org>; Tue, 26 Oct 1999 09:58:12 +0800
Message-Id: <199910260158.JAA00043@chpc.ict.ac.cn>
Date: Tue, 26 Oct 1999 9:57:48 +0800
From: fxzhang <fxzhang@chpc.ict.ac.cn>
Reply-To: fxzhang@chpc.ict.ac.cn
Subject: Why don't we make mmap MAP_SHARED with /dev/zero possible?
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

and find this:
 /usr/src/linux/drivers/char/mem.c  
static int mmap_zero(struct file * file, struct vm_area_struct * vma)
{
        if (vma->vm_flags & VM_SHARED)
                return -EINVAL;

I don't understand why people don't implement it.Yes,in the source,I find something like
"the shared case is complex",Could someone tell me what's the difficulty?As it is a 
driver,I think it should not be too much to concern.At least I know in Solaris this works.
   I want to implement it but know I am not competent now,I am just beginning digging it:).
   
   Is there any good way to share memory between process at page granularity?That is,I can
share individual pages between them? Threads maybe a subtitue,but there are many things
that I don't want to share.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
