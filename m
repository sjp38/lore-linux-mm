Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id A04526B0035
	for <linux-mm@kvack.org>; Thu, 21 Aug 2014 05:26:32 -0400 (EDT)
Received: by mail-wi0-f169.google.com with SMTP id n3so7812188wiv.0
        for <linux-mm@kvack.org>; Thu, 21 Aug 2014 02:26:32 -0700 (PDT)
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
        by mx.google.com with ESMTPS id eg5si40638259wjd.70.2014.08.21.02.26.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 21 Aug 2014 02:26:31 -0700 (PDT)
Received: by mail-wi0-f178.google.com with SMTP id hi2so8135906wib.17
        for <linux-mm@kvack.org>; Thu, 21 Aug 2014 02:26:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1408610714-16204-3-git-send-email-m.szyprowski@samsung.com>
References: <1408610714-16204-1-git-send-email-m.szyprowski@samsung.com>
	<1408610714-16204-3-git-send-email-m.szyprowski@samsung.com>
Date: Thu, 21 Aug 2014 10:26:30 +0100
Message-ID: <CAD8Lp44MHLv_C0SscRAxq_09Ux+Uz=9B3KvDKvUkamBenoSm=Q@mail.gmail.com>
Subject: Re: [PATCH 2/2] ARM: mm: don't limit default CMA region only to low memory
From: Daniel Drake <drake@endlessm.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Michal Nazarewicz <mina86@mina86.com>

Hi Marek,

On Thu, Aug 21, 2014 at 9:45 AM, Marek Szyprowski
<m.szyprowski@samsung.com> wrote:
> DMA-mapping supports CMA regions places either in low or high memory, so
> there is no longer needed to limit default CMA regions only to low memory.
> The real limit is still defined by architecture specific DMA limit.

Thanks for working on this!

I think you need to update the comment here though, which still says:
    /*
     * reserve memory for DMA contigouos allocations,
     * must come from DMA area inside low memory
     */

If you're making a second version, as a minor nitpick you could also
s/places/placed in the commit message.

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
