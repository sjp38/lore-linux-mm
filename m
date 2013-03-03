Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 717C16B0007
	for <linux-mm@kvack.org>; Sun,  3 Mar 2013 12:13:29 -0500 (EST)
Received: by mail-pb0-f49.google.com with SMTP id xa12so2587657pbc.8
        for <linux-mm@kvack.org>; Sun, 03 Mar 2013 09:13:28 -0800 (PST)
Message-ID: <513384B2.9090308@gmail.com>
Date: Mon, 04 Mar 2013 01:13:22 +0800
From: Jiang Liu <liuj97@gmail.com>
MIME-Version: 1.0
Subject: Re: mm: introduce new field "managed_pages" to struct zone
References: <512EF580.6000608@gmail.com> <5132D918.2000009@gmail.com>
In-Reply-To: <5132D918.2000009@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ric Mason <ric.masonn@gmail.com>
Cc: Simon Jeons <simon.jeons@gmail.com>, Jiang Liu <jiang.liu@huawei.com>, "linux-mm@kvack.org >> Linux Memory Management List" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Yinghai Lu <yinghai@kernel.org>

On 03/03/2013 01:01 PM, Ric Mason wrote:
> On 02/28/2013 02:13 PM, Simon Jeons wrote:
>> Hi Jiang,
>>
>> https://patchwork.kernel.org/patch/1781291/
>>
>> You said that the bootmem allocator doesn't touch *highmem pages*, so highmem zones' managed_pages is set to the accurate value "spanned_pages - absent_pages" in function free_area_init_core() and won't be updated anymore. Why it doesn't touch *highmem pages*? Could you point out where you figure out this?
> 
> Yeah, why bootmem doesn't touch highmem pages? The patch is buggy. :(
> 
Actually I found that assumption may be wrong for some architectures, and I'm
working on a patchset to clean it up. BTW, what's the issue with that patch?
Regards!
Gerry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
