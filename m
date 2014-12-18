Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f172.google.com (mail-ie0-f172.google.com [209.85.223.172])
	by kanga.kvack.org (Postfix) with ESMTP id 96DA76B006E
	for <linux-mm@kvack.org>; Thu, 18 Dec 2014 12:01:31 -0500 (EST)
Received: by mail-ie0-f172.google.com with SMTP id tr6so1495587ieb.17
        for <linux-mm@kvack.org>; Thu, 18 Dec 2014 09:01:31 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id z15si6112878icf.64.2014.12.18.09.00.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Dec 2014 09:00:46 -0800 (PST)
Message-ID: <54930835.8020009@codeaurora.org>
Date: Thu, 18 Dec 2014 09:00:37 -0800
From: Laura Abbott <lauraa@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [RFC PATCH] mm: cma: add functions for getting allocation info
References: <1418854236-25140-1-git-send-email-gregory.0xf0@gmail.com>
In-Reply-To: <1418854236-25140-1-git-send-email-gregory.0xf0@gmail.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gregory Fong <gregory.0xf0@gmail.com>, linux-mm@kvack.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Weijie Yang <weijie.yang@samsung.com>, Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>, open list <linux-kernel@vger.kernel.org>

On 12/17/2014 2:10 PM, Gregory Fong wrote:
> These functions allow for retrieval of information on what is allocated from
> within a given CMA region.  It can be useful to know the number of distinct
> contiguous allocations and where in the region those allocations are located.
>
> Based on an initial version by Marc Carino <marc.ceeeee@gmail.com> in a driver
> that used the CMA bitmap directly; this instead moves the logic into the core
> CMA API.
>
> Signed-off-by: Gregory Fong <gregory.0xf0@gmail.com>
> ---
> This has been really useful for us to determine allocation information for a
> CMA region.  We have had a separate driver that might not be appropriate for
> upstream, but allowed using a user program to run CMA unit tests to verify that
> allocations end up where they we would expect.  This addition would allow for
> that without needing to expose the CMA bitmap.  Wanted to put this out there to
> see if anyone else would be interested, comments and suggestions welcome.
>

Information is definitely useful but I'm not sure how it's intended to
be used. Do you have a sample usage of these APIs? Another option might
be to just add regular debugfs support for each of the regions instead
of just calling out to a separate driver.

Thanks,
Laura

-- 
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
