Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1B8766B0033
	for <linux-mm@kvack.org>; Wed,  4 Oct 2017 13:08:59 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id k123so10665201qke.5
        for <linux-mm@kvack.org>; Wed, 04 Oct 2017 10:08:59 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id g206si5613041qkb.542.2017.10.04.10.08.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Oct 2017 10:08:57 -0700 (PDT)
Subject: Re: [RFC] mmap(MAP_CONTIG)
References: <21f1ec96-2822-1189-1c95-79a2bb491571@oracle.com>
 <xa1tk20bxh5u.fsf@mina86.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <c00b355a-cfb7-a4e0-56a3-01430dc9e9f5@oracle.com>
Date: Wed, 4 Oct 2017 10:08:50 -0700
MIME-Version: 1.0
In-Reply-To: <xa1tk20bxh5u.fsf@mina86.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Guy Shattah <sguy@mellanox.com>, Christoph Lameter <cl@linux.com>

On 10/04/2017 04:54 AM, Michal Nazarewicz wrote:
> On Tue, Oct 03 2017, Mike Kravetz wrote:
>> At Plumbers this year, Guy Shattah and Christoph Lameter gave a presentation
>> titled 'User space contiguous memory allocation for DMA' [1].  The slides
>> point out the performance benefits of devices that can take advantage of
>> larger physically contiguous areas.
> 
> Issue I have is that kind of memory needed may depend on a device.  Some
> may require contiguous blocks.  Some may support scatter-gather.  Some
> may be behind IO-MMU and not care either way.
> 
> Furthermore, I feel dA(C)jA  vu.  Wasna??t dmabuf supposed to address this
> issue?

Thanks Michal,

I was unaware of dmabuf and am just now looking at capabilities.  The
question is whether or not the IB driver writers requesting mmap(MAP_CONTIG)
functionality could make use of dmabuf.  That is out of my are of expertise,
so I will let them reply.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
