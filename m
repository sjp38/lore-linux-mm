Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 027886B01F2
	for <linux-mm@kvack.org>; Sat, 15 May 2010 10:31:22 -0400 (EDT)
Received: by fxm20 with SMTP id 20so1697071fxm.14
        for <linux-mm@kvack.org>; Sat, 15 May 2010 07:31:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1005141626250.20193@router.home>
References: <1273869997-12720-1-git-send-email-gthelen@google.com>
	 <alpine.DEB.2.00.1005141626250.20193@router.home>
Date: Sat, 15 May 2010 23:31:16 +0900
Message-ID: <AANLkTil4zgqBtBAp--P8VdynpbohxVosQ-qFiQQ_c5Bb@mail.gmail.com>
Subject: Re: [PATCH] mm: Consider the entire user address space during node
	migration
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Greg Thelen <gthelen@google.com>, Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Mel Gorman <mel@csn.ul.ie>, kamezawa.hiroyu@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp, balbir@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi

Mysteriously, I haven't receive original post.
So now I'm guessing you acked following patch.

http://lkml.org/lkml/2010/5/14/393

but I don't think it is correct.

> -	check_range(mm, mm->mmap->vm_start, TASK_SIZE, &nmask,
> +	check_range(mm, mm->mmap->vm_start, TASK_SIZE_MAX, &nmask,
> 			flags | MPOL_MF_DISCONTIG_OK, &pagelist);

Because TASK_SIZE_MAX is defined on x86 only. Why can we ignore other platform?
Please put following line anywhere.

#define TASK_SIZE_MAX TASK_SIZE


But this patch is conceptually good. if it fixes the bug. I'll ack gladly.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
