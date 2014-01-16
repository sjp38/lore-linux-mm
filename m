Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f179.google.com (mail-we0-f179.google.com [74.125.82.179])
	by kanga.kvack.org (Postfix) with ESMTP id A52F46B0039
	for <linux-mm@kvack.org>; Thu, 16 Jan 2014 11:37:44 -0500 (EST)
Received: by mail-we0-f179.google.com with SMTP id w62so3481160wes.10
        for <linux-mm@kvack.org>; Thu, 16 Jan 2014 08:37:44 -0800 (PST)
Received: from mail-wg0-x236.google.com (mail-wg0-x236.google.com [2a00:1450:400c:c00::236])
        by mx.google.com with ESMTPS id cx3si15736275wib.1.2014.01.16.08.37.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 16 Jan 2014 08:37:43 -0800 (PST)
Received: by mail-wg0-f54.google.com with SMTP id x13so3468283wgg.9
        for <linux-mm@kvack.org>; Thu, 16 Jan 2014 08:37:43 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20140116164936.1c6c3274@lilie>
References: <1389879186-43649-1-git-send-email-phacht@linux.vnet.ibm.com>
	<CAPp3RGpWhx4uoTTiSkUe9rZ2iJjMW6O2u=xdWL7BSskse=61qw@mail.gmail.com>
	<20140116164936.1c6c3274@lilie>
Date: Thu, 16 Jan 2014 10:37:43 -0600
Message-ID: <CAPp3RGpt+qjFYrA928hBjseJNo4v0RKVnb-BjFJzH0uaVGcX+g@mail.gmail.com>
Subject: Re: [PATCH] mm/nobootmem: Fix unused variable
From: Robin Holt <robinmholt@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Philipp Hachtmann <phacht@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, liuj97@gmail.com, santosh.shilimkar@ti.com, grygorii.strashko@ti.com, iamjoonsoo.kim@lge.com, robin.m.holt@gmail.com, yinghai@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Since your patch set is the _ONLY_ thing that introduces #ifdef's
inside functions within
this file, I would think you would be better off making
get_allocated_memblock_reserved_regions_info() and
get_allocated_memblock_memory_regions_info be static inline functions
when #ifdef CONFIG_ARCH_DISCARD_MEMBLOCK.

That said, I don't have a fundamental objection to #ifdef's inside
functions so...

Acked-by: Robin Holt <robinmholt@gmail.com>

On Thu, Jan 16, 2014 at 9:49 AM, Philipp Hachtmann
<phacht@linux.vnet.ibm.com> wrote:
> Hi Robin,
>
>>  Maybe you are working off a different repo than
>> Linus' latest?  Your line 116 is my 114.  Maybe the message needs to
>> be a bit more descriptive
>
> Ah, yes. This fits Andrew's linux-next.
>
> Regards
>
> Philipp
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
