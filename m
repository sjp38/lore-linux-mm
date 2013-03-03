Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 510B56B0002
	for <linux-mm@kvack.org>; Sun,  3 Mar 2013 18:57:16 -0500 (EST)
Received: by mail-ie0-f178.google.com with SMTP id c13so5398831ieb.23
        for <linux-mm@kvack.org>; Sun, 03 Mar 2013 15:57:15 -0800 (PST)
Message-ID: <5133E356.6000502@gmail.com>
Date: Mon, 04 Mar 2013 07:57:10 +0800
From: Simon Jeons <simon.jeons@gmail.com>
MIME-Version: 1.0
Subject: Re: mm: introduce new field "managed_pages" to struct zone
References: <512EF580.6000608@gmail.com> <51336FB4.9000202@gmail.com>
In-Reply-To: <51336FB4.9000202@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <liuj97@gmail.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, "linux-mm@kvack.org >> Linux Memory Management List" <linux-mm@kvack.org>


Hi Jiang,
On 03/03/2013 11:43 PM, Jiang Liu wrote:
> Hi Simon,
> 	Bootmem allocator is used to managed DMA and Normal memory only, and it does not manage highmem pages because kernel
> can't directly access highmem pages.

Why you say so? Could you point out where you figure out bootmem 
allocator doesn't handle highmem pages? In my understanding, it doesn't 
distinguish low memory or high memory.

> 	Regards!
> 	Gerry
>
> On 02/28/2013 02:13 PM, Simon Jeons wrote:
>> Hi Jiang,
>>
>> https://patchwork.kernel.org/patch/1781291/
>>
>> You said that the bootmem allocator doesn't touch *highmem pages*, so highmem zones' managed_pages is set to the accurate value "spanned_pages - absent_pages" in function free_area_init_core() and won't be updated anymore. Why it doesn't touch *highmem pages*? Could you point out where you figure out this?
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
