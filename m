Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f49.google.com (mail-qa0-f49.google.com [209.85.216.49])
	by kanga.kvack.org (Postfix) with ESMTP id 25C5D6B0035
	for <linux-mm@kvack.org>; Mon, 12 May 2014 12:57:20 -0400 (EDT)
Received: by mail-qa0-f49.google.com with SMTP id cm18so7265548qab.36
        for <linux-mm@kvack.org>; Mon, 12 May 2014 09:57:19 -0700 (PDT)
Received: from qmta04.emeryville.ca.mail.comcast.net (qmta04.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:40])
        by mx.google.com with ESMTP id d3si2845767qar.225.2014.05.12.09.57.19
        for <linux-mm@kvack.org>;
        Mon, 12 May 2014 09:57:19 -0700 (PDT)
Date: Mon, 12 May 2014 11:57:15 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/3] mm: add comment for __mod_zone_page_stat
In-Reply-To: <1399912423-25601-1-git-send-email-nasa4836@gmail.com>
Message-ID: <alpine.DEB.2.10.1405121155220.26638@gentwo.org>
References: <1399912423-25601-1-git-send-email-nasa4836@gmail.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianyu Zhan <nasa4836@gmail.com>
Cc: akpm@linux-foundation.org, riel@redhat.com, aarcange@redhat.com, oleg@redhat.com, cldu@marvell.com, fabf@skynet.be, sasha.levin@oracle.com, zhangyanfei@cn.fujitsu.com, iamjoonsoo.kim@lge.com, n-horiguchi@ah.jp.nec.com, kirill.shutemov@linux.intel.com, liwanp@linux.vnet.ibm.com, gorcunov@gmail.com, minchan@kernel.org, dave.hansen@linux.intel.com, toshi.kani@hp.com, paul.gortmaker@windriver.com, srivatsa.bhat@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>

On Tue, 13 May 2014, Jianyu Zhan wrote:

> diff --git a/mm/internal.h b/mm/internal.h
> index 07b6736..53d439e 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -196,7 +196,12 @@ static inline int mlocked_vma_newpage(struct vm_area_struct *vma,
>  		return 0;
>
>  	if (!TestSetPageMlocked(page)) {
> -		mod_zone_page_state(page_zone(page), NR_MLOCK,
> +		/*
> +		 * We use the irq-unsafe __mod_zone_page_stat because
> +		 * this counter is not modified from interrupt context, and the
> +		 * pte lock is held(spinlock), which implies preemtion disabled.

Preemption is mis-spelled throughout.

Otherwise

Reviewed-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
