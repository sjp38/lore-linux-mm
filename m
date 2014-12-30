Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f52.google.com (mail-oi0-f52.google.com [209.85.218.52])
	by kanga.kvack.org (Postfix) with ESMTP id 35A446B0038
	for <linux-mm@kvack.org>; Tue, 30 Dec 2014 05:02:51 -0500 (EST)
Received: by mail-oi0-f52.google.com with SMTP id a3so1287089oib.11
        for <linux-mm@kvack.org>; Tue, 30 Dec 2014 02:02:51 -0800 (PST)
Received: from mail-oi0-x232.google.com (mail-oi0-x232.google.com. [2607:f8b0:4003:c06::232])
        by mx.google.com with ESMTPS id cq6si7523385oeb.82.2014.12.30.02.02.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 30 Dec 2014 02:02:50 -0800 (PST)
Received: by mail-oi0-f50.google.com with SMTP id x69so31952841oia.9
        for <linux-mm@kvack.org>; Tue, 30 Dec 2014 02:02:49 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20141230044826.GC4588@js1304-P5Q-DELUXE>
References: <1419500608-11656-1-git-send-email-zhuhui@xiaomi.com>
 <1419500608-11656-2-git-send-email-zhuhui@xiaomi.com> <20141230044826.GC4588@js1304-P5Q-DELUXE>
From: Hui Zhu <teawater@gmail.com>
Date: Tue, 30 Dec 2014 18:02:09 +0800
Message-ID: <CANFwon3U+chGmvLG_HdMf5_0Mb5OEEJSOUr+oPB5+US3rnfguA@mail.gmail.com>
Subject: Re: [PATCH 1/3] CMA: Fix the bug that CMA's page number is
 substructed twice
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Hui Zhu <zhuhui@xiaomi.com>, m.szyprowski@samsung.com, mina86@mina86.com, Andrew Morton <akpm@linux-foundation.org>, aneesh.kumar@linux.vnet.ibm.com, pintu.k@samsung.com, weijie.yang@samsung.com, mgorman@suse.de, hannes@cmpxchg.org, Rik van Riel <riel@redhat.com>, vbabka@suse.cz, laurent.pinchart+renesas@ideasonboard.com, rientjes@google.com, sasha.levin@oracle.com, liuweixing@xiaomi.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Tue, Dec 30, 2014 at 12:48 PM, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> On Thu, Dec 25, 2014 at 05:43:26PM +0800, Hui Zhu wrote:
>> In Joonsoo's CMA patch "CMA: always treat free cma pages as non-free on
>> watermark checking" [1], it changes __zone_watermark_ok to substruct CMA
>> pages number from free_pages if system use CMA:
>>       if (IS_ENABLED(CONFIG_CMA) && z->managed_cma_pages)
>>               free_pages -= zone_page_state(z, NR_FREE_CMA_PAGES);
>
> Hello,
>
> In fact, without that patch, watermark checking has a problem in current kernel.
> If there is reserved CMA region, watermark check for high order
> allocation is done loosly. See following thread.
>
> https://lkml.org/lkml/2014/5/30/320
>
> Your patch can fix this situation, so, how about submitting this patch
> separately?
>
> Thanks.
>

Hi Joonsoo,

Thanks for your remind.  I will post a separate patch for current kernel.

Thanks,
Hui

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
