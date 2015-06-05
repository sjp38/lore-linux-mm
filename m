Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 7EEBD900016
	for <linux-mm@kvack.org>; Thu,  4 Jun 2015 23:19:43 -0400 (EDT)
Received: by padj3 with SMTP id j3so41714232pad.0
        for <linux-mm@kvack.org>; Thu, 04 Jun 2015 20:19:43 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id dv10si1549670pdb.202.2015.06.04.20.19.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 04 Jun 2015 20:19:42 -0700 (PDT)
Message-ID: <55711428.8020006@huawei.com>
Date: Fri, 5 Jun 2015 11:14:48 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 10/12] mm: add the buddy system interface
References: <55704A7E.5030507@huawei.com> <55704CC4.8040707@huawei.com> <3908561D78D1C84285E8C5FCA982C28F32A8D5C7@ORSMSX114.amr.corp.intel.com>
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F32A8D5C7@ORSMSX114.amr.corp.intel.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "nao.horiguchi@gmail.com" <nao.horiguchi@gmail.com>, Yinghai Lu <yinghai@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, "mingo@elte.hu" <mingo@elte.hu>, Xiexiuqi <xiexiuqi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2015/6/5 1:09, Luck, Tony wrote:

> +#ifdef CONFIG_MEMORY_MIRROR
> +	if (change_to_mirror(gfp_mask, ac.high_zoneidx))
> +		ac.migratetype = MIGRATE_MIRROR;
> +#endif
> 
> We may have to be smarter than this here. I'd like to encourage the
> enterprise Linux distributions to set CONFIG_MEMORY_MIRROR=y
> But the reality is that most systems will not configure any mirrored
> memory - so we don't want the common code path for memory
> allocation to call functions that set the migrate type, try to allocate
> and then fall back to a non-mirror when that may be a complete waste
> of time.
> 
> Maybe a global "got_mirror" that is true if we have some mirrored
> memory.  Then code is
> 
> 	if (got_mirror && change_to_mirror(...))
> 

Yes, I will change next time.

Thanks,

> .
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
