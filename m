Date: Fri, 8 Dec 2000 13:06:33 +0100
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: New patches for 2.2.18pre24 raw IO (fix for bounce buffer copy)
Message-ID: <20001208130633.A31920@inspiron.random>
References: <20001204205004.H8700@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20001204205004.H8700@redhat.com>; from sct@redhat.com on Mon, Dec 04, 2000 at 08:50:04PM +0000
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-kernel@vger.kernel.org, Andi Kleen <ak@muc.de>, wtenhave@sybase.com, hdeller@redhat.com, Eric Lowe <elowe@myrile.madriver.k12.oh.us>, Larry Woodman <woodman@missioncriticallinux.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Dec 04, 2000 at 08:50:04PM +0000, Stephen C. Tweedie wrote:
> I have pushed another set of raw IO patches out, this time to fix a

This fix is missing:

--- rawio-sct/mm/memory.c.~1~	Fri Dec  8 03:05:01 2000
+++ rawio-sct/mm/memory.c	Fri Dec  8 03:57:48 2000
@@ -455,7 +455,7 @@
 	unsigned long		ptr, end;
 	int			err;
 	struct mm_struct *	mm;
-	struct vm_area_struct *	vma = 0;
+	struct vm_area_struct *	vma;
 	unsigned long		page;
 	struct page *		map;
 	int			doublepage = 0;
@@ -478,6 +478,7 @@
 		return err;
 
  repeat:
+	vma = NULL;
 	down(&mm->mmap_sem);
 
 	err = -EFAULT;
Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
