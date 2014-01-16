Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f179.google.com (mail-we0-f179.google.com [74.125.82.179])
	by kanga.kvack.org (Postfix) with ESMTP id F2FBA6B0031
	for <linux-mm@kvack.org>; Thu, 16 Jan 2014 16:25:04 -0500 (EST)
Received: by mail-we0-f179.google.com with SMTP id w62so3701586wes.24
        for <linux-mm@kvack.org>; Thu, 16 Jan 2014 13:25:04 -0800 (PST)
Received: from mail-we0-x231.google.com (mail-we0-x231.google.com [2a00:1450:400c:c03::231])
        by mx.google.com with ESMTPS id dj2si6818470wjc.7.2014.01.16.13.25.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 16 Jan 2014 13:25:04 -0800 (PST)
Received: by mail-we0-f177.google.com with SMTP id x55so3651409wes.8
        for <linux-mm@kvack.org>; Thu, 16 Jan 2014 13:25:04 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20140116184121.34d1e97c@lilie>
References: <1389879186-43649-1-git-send-email-phacht@linux.vnet.ibm.com>
	<CAPp3RGpWhx4uoTTiSkUe9rZ2iJjMW6O2u=xdWL7BSskse=61qw@mail.gmail.com>
	<20140116164936.1c6c3274@lilie>
	<CAPp3RGpt+qjFYrA928hBjseJNo4v0RKVnb-BjFJzH0uaVGcX+g@mail.gmail.com>
	<20140116184121.34d1e97c@lilie>
Date: Thu, 16 Jan 2014 15:25:04 -0600
Message-ID: <CAPp3RGp2qi0mLnbZv1ZZuKnz+1yqV2gC1LfP3xxhmhosoBNhzg@mail.gmail.com>
Subject: Re: [PATCH] mm/nobootmem: Fix unused variable
From: Robin Holt <robinmholt@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Philipp Hachtmann <phacht@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Jiang Liu <liuj97@gmail.com>, santosh.shilimkar@ti.com, grygorii.strashko@ti.com, iamjoonsoo.kim@lge.com, Robin Holt <robin.m.holt@gmail.com>, yinghai@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

If the definition of the
get_allocated_memblock_reserved_regions_info() function when
CONFIG_ARCH_DISCARD_MEMBLOCK simply returns 0, the compiler will see
that size is defined, the optimizer will see that it is always 0 and
that the if(0) is always false.  The net result will be no code will
be produced and the function will be less cluttered.

On Thu, Jan 16, 2014 at 11:41 AM, Philipp Hachtmann
<phacht@linux.vnet.ibm.com> wrote:
>
>> I would think you would be better off making
>> get_allocated_memblock_reserved_regions_info() and
>> get_allocated_memblock_memory_regions_info be static inline functions
>> when #ifdef CONFIG_ARCH_DISCARD_MEMBLOCK.
> Possible, of course.
> But the size variable has still to be #ifdef'd. And that's what the
> patch is about. It's just an addition to another patch.
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
