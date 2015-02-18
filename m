Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 0CB646B0072
	for <linux-mm@kvack.org>; Wed, 18 Feb 2015 05:06:27 -0500 (EST)
Received: by pdbnh10 with SMTP id nh10so63722pdb.11
        for <linux-mm@kvack.org>; Wed, 18 Feb 2015 02:06:26 -0800 (PST)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id te3si23959175pab.230.2015.02.18.02.06.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Wed, 18 Feb 2015 02:06:26 -0800 (PST)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NJY005OHPLAGR60@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 18 Feb 2015 10:10:22 +0000 (GMT)
Message-id: <54E4641A.9050709@partner.samsung.com>
Date: Wed, 18 Feb 2015 13:06:18 +0300
From: Stefan Strogin <s.strogin@partner.samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH 1/4] mm: cma: add currently allocated CMA buffers list to
 debugfs
References: <cover.1423777850.git.s.strogin@partner.samsung.com>
 <c4f408198ec7ea7656ae29220c1f96081bd2ade5.1423777850.git.s.strogin@partner.samsung.com>
 <20150213031613.GJ6592@js1304-P5Q-DELUXE>
In-reply-to: <20150213031613.GJ6592@js1304-P5Q-DELUXE>
Content-type: text/plain; charset=windows-1252
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, aneesh.kumar@linux.vnet.ibm.com, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Dmitry Safonov <d.safonov@partner.samsung.com>, Pintu Kumar <pintu.k@samsung.com>, Weijie Yang <weijie.yang@samsung.com>, Laura Abbott <lauraa@codeaurora.org>, SeongJae Park <sj38.park@gmail.com>, Hui Zhu <zhuhui@xiaomi.com>, Minchan Kim <minchan@kernel.org>, Dyasly Sergey <s.dyasly@samsung.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>, gregory.0xf0@gmail.com, sasha.levin@oracle.com, gioh.kim@lge.com, pavel@ucw.cz, stefan.strogin@gmail.com

Hello

On 13/02/15 06:16, Joonsoo Kim wrote:
> On Fri, Feb 13, 2015 at 01:15:41AM +0300, Stefan Strogin wrote:
>>  static int cma_debugfs_get(void *data, u64 *val)
>>  {
>>  	unsigned long *p = data;
>> @@ -125,6 +221,52 @@ static int cma_alloc_write(void *data, u64 val)
>>  
>>  DEFINE_SIMPLE_ATTRIBUTE(cma_alloc_fops, NULL, cma_alloc_write, "%llu\n");
>>  
>> +static int cma_buffers_read(struct file *file, char __user *userbuf,
>> +				size_t count, loff_t *ppos)
>> +{
>> +	struct cma *cma = file->private_data;
>> +	struct cma_buffer *cmabuf;
>> +	struct stack_trace trace;
>> +	char *buf;
>> +	int ret, n = 0;
>> +
>> +	if (*ppos < 0 || !count)
>> +		return -EINVAL;
>> +
>> +	buf = kmalloc(count, GFP_KERNEL);
>> +	if (!buf)
>> +		return -ENOMEM;
> 
> Is count limited within proper size boundary for kmalloc()?
> If it can exceed page size, using vmalloc() is better than this.
> 
> Thanks.
> 

You are right. On my systems it is always much bigger than page size.
Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
