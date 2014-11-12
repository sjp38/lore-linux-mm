Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id E167A6B00C2
	for <linux-mm@kvack.org>; Tue, 11 Nov 2014 22:16:57 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id kq14so12036560pab.10
        for <linux-mm@kvack.org>; Tue, 11 Nov 2014 19:16:57 -0800 (PST)
Received: from fgwmail6.fujitsu.co.jp (fgwmail6.fujitsu.co.jp. [192.51.44.36])
        by mx.google.com with ESMTPS id oq7si883718pdb.55.2014.11.11.19.16.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 11 Nov 2014 19:16:56 -0800 (PST)
Received: from kw-mxauth.gw.nic.fujitsu.com (unknown [10.0.237.134])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 9D1443EE0C5
	for <linux-mm@kvack.org>; Wed, 12 Nov 2014 12:16:54 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by kw-mxauth.gw.nic.fujitsu.com (Postfix) with ESMTP id 9DAC0AC05C9
	for <linux-mm@kvack.org>; Wed, 12 Nov 2014 12:16:53 +0900 (JST)
Received: from g01jpfmpwkw01.exch.g01.fujitsu.local (g01jpfmpwkw01.exch.g01.fujitsu.local [10.0.193.38])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 342E31DB8042
	for <linux-mm@kvack.org>; Wed, 12 Nov 2014 12:16:53 +0900 (JST)
Message-ID: <5462D0F5.1050008@jp.fujitsu.com>
Date: Wed, 12 Nov 2014 12:16:05 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memory-hotplug: remove redundant call of page_to_pfn
References: <1415697184-26409-1-git-send-email-zhenzhang.zhang@huawei.com> <5461D343.60803@huawei.com>
In-Reply-To: <5461D343.60803@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Zhen <zhenzhang.zhang@huawei.com>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Linux MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, wangnan0@huawei.com

(2014/11/11 18:13), Zhang Zhen wrote:
> The start_pfn can be obtained directly by
> phys_index << PFN_SECTION_SHIFT.
>
> Signed-off-by: Zhang Zhen <zhenzhang.zhang@huawei.com>
> ---

The patch looks good to me but I want you to write a purpose of the patch
to the description for other reviewer.

Thanks,
Yasuaki Ishimatsu

>   drivers/base/memory.c | 4 ++--
>   1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> index 7c5d871..85be040 100644
> --- a/drivers/base/memory.c
> +++ b/drivers/base/memory.c
> @@ -228,8 +228,8 @@ memory_block_action(unsigned long phys_index, unsigned long action, int online_t
>   	struct page *first_page;
>   	int ret;
>
> -	first_page = pfn_to_page(phys_index << PFN_SECTION_SHIFT);
> -	start_pfn = page_to_pfn(first_page);
> +	start_pfn = phys_index << PFN_SECTION_SHIFT;
> +	first_page = pfn_to_page(start_pfn);
>
>   	switch (action) {
>   		case MEM_ONLINE:
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
