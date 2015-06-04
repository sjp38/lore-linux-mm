Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 97501900016
	for <linux-mm@kvack.org>; Thu,  4 Jun 2015 14:44:41 -0400 (EDT)
Received: by payr10 with SMTP id r10so34887285pay.1
        for <linux-mm@kvack.org>; Thu, 04 Jun 2015 11:44:41 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id di10si7109835pdb.34.2015.06.04.11.44.40
        for <linux-mm@kvack.org>;
        Thu, 04 Jun 2015 11:44:40 -0700 (PDT)
Message-ID: <55709C98.1030005@intel.com>
Date: Thu, 04 Jun 2015 11:44:40 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 11/12] mm: add the PCP interface
References: <55704A7E.5030507@huawei.com> <55704CED.1020702@huawei.com>
In-Reply-To: <55704CED.1020702@huawei.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, nao.horiguchi@gmail.com, Yinghai Lu <yinghai@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, mingo@elte.hu, Xiexiuqi <xiexiuqi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, "Luck, Tony" <tony.luck@intel.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 06/04/2015 06:04 AM, Xishi Qiu wrote:
>  	spin_lock(&zone->lock);
>  	for (i = 0; i < count; ++i) {
> -		struct page *page = __rmqueue(zone, order, migratetype);
> +		struct page *page;
> +
> +		if (is_migrate_mirror(migratetype))
> +			page = __rmqueue_smallest(zone, order, migratetype);
> +		else
> +			page = __rmqueue(zone, order, migratetype);
>  		if (unlikely(page == NULL))
>  			break;

Why is this necessary/helpful?  The changelog doesn't tell me either. :(

Why was this code modified in stead of putting the changes in
__rmqueue() itself (like CMA did)?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
