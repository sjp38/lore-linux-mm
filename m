Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id C71146B00E6
	for <linux-mm@kvack.org>; Thu,  2 Dec 2010 01:40:11 -0500 (EST)
Date: Thu, 2 Dec 2010 01:40:05 -0500 (EST)
From: CAI Qian <caiqian@redhat.com>
Message-ID: <84515836.1031531291272005978.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
In-Reply-To: <AANLkTi=Fy0sqDNai4SUuzvJ+5-+c5EjVLtuozOr_Fkgk@mail.gmail.com>
Subject: Re: oom is broken in mmotm 2010-11-09-15-31 tree?
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>


> Ok, this does seem like a lot of pages are busy, so shrink_page_list
> ends up just looping.
> 
> And that is indeed the bug that commit d88c0922fa0e should have
> fixed.
> 
> So please check whether the kernel you are running has that fix
> applied to it or not.
Indeed, I was able to reproduce it anymore after applied this patch. Thanks.

CAI Qian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
