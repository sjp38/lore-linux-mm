Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 2FD386B0044
	for <linux-mm@kvack.org>; Wed,  5 Dec 2012 17:14:45 -0500 (EST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 3/3] HWPOISON, hugetlbfs: fix RSS-counter warning
Date: Wed,  5 Dec 2012 17:14:33 -0500
Message-Id: <1354745673-31035-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F1C963B15@ORSMSX108.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@intel.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi.kleen@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Tony,

On Wed, Dec 05, 2012 at 10:04:50PM +0000, Luck, Tony wrote:
> 	if (PageHWPoison(page) && !(flags & TTU_IGNORE_HWPOISON)) {
> -		if (PageAnon(page))
> +		if (PageHuge(page))
> +			;
> +		else if (PageAnon(page))
>  			dec_mm_counter(mm, MM_ANONPAGES);
>  		else
>  			dec_mm_counter(mm, MM_FILEPAGES);
> 
> This style minimizes the "diff" ... but wouldn't it be nicer to say:
> 
> 		if (!PageHuge(page)) {
> 			old code in here
> 		}
> 

I think this need more lines in diff because old code should be
indented without any logical change.

Thanks,
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
