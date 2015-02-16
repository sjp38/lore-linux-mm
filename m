Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 8D6976B0032
	for <linux-mm@kvack.org>; Mon, 16 Feb 2015 14:19:17 -0500 (EST)
Received: by pdbfp1 with SMTP id fp1so38271390pdb.9
        for <linux-mm@kvack.org>; Mon, 16 Feb 2015 11:19:17 -0800 (PST)
Received: from mailout3.w1.samsung.com (mailout3.w1.samsung.com. [210.118.77.13])
        by mx.google.com with ESMTPS id w7si16939616pdn.84.2015.02.16.11.19.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Mon, 16 Feb 2015 11:19:15 -0800 (PST)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NJV00FZIPUQRIA0@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 16 Feb 2015 19:23:14 +0000 (GMT)
Message-id: <54E242AC.1040200@partner.samsung.com>
Date: Mon, 16 Feb 2015 22:19:08 +0300
From: Stefan Strogin <s.strogin@partner.samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH 1/4] mm: cma: add currently allocated CMA buffers list to
 debugfs
References: <cover.1423777850.git.s.strogin@partner.samsung.com>
 <c4f408198ec7ea7656ae29220c1f96081bd2ade5.1423777850.git.s.strogin@partner.samsung.com>
 <20150213031012.GH6592@js1304-P5Q-DELUXE>
In-reply-to: <20150213031012.GH6592@js1304-P5Q-DELUXE>
Content-type: text/plain; charset=windows-1252
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, aneesh.kumar@linux.vnet.ibm.com, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Dmitry Safonov <d.safonov@partner.samsung.com>, Pintu Kumar <pintu.k@samsung.com>, Weijie Yang <weijie.yang@samsung.com>, Laura Abbott <lauraa@codeaurora.org>, SeongJae Park <sj38.park@gmail.com>, Hui Zhu <zhuhui@xiaomi.com>, Minchan Kim <minchan@kernel.org>, Dyasly Sergey <s.dyasly@samsung.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>, gregory.0xf0@gmail.com, sasha.levin@oracle.com, gioh.kim@lge.com, pavel@ucw.cz, stefan.strogin@gmail.com



On 13/02/15 06:10, Joonsoo Kim wrote:
>> @@ -28,4 +28,13 @@ extern int cma_init_reserved_mem(phys_addr_t base,
>>  					struct cma **res_cma);
>>  extern struct page *cma_alloc(struct cma *cma, int count, unsigned int align);
>>  extern bool cma_release(struct cma *cma, struct page *pages, int count);
>> +
>> +#ifdef CONFIG_CMA_DEBUGFS
>> +extern int cma_buffer_list_add(struct cma *cma, unsigned long pfn, int count);
>> +extern void cma_buffer_list_del(struct cma *cma, unsigned long pfn, int count);
>> +#else
>> +#define cma_buffer_list_add(cma, pfn, count) { }
>> +#define cma_buffer_list_del(cma, pfn, count) { }
>> +#endif
>> +
> 
> These could be in mm/cma.h rather than include/linux/cma.h.
> 

Thank you. I'll correct it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
