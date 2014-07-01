Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f181.google.com (mail-ie0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id AA92C6B0035
	for <linux-mm@kvack.org>; Mon, 30 Jun 2014 22:02:47 -0400 (EDT)
Received: by mail-ie0-f181.google.com with SMTP id rl12so81868iec.40
        for <linux-mm@kvack.org>; Mon, 30 Jun 2014 19:02:47 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id r10si32036975ico.103.2014.06.30.19.02.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Jun 2014 19:02:46 -0700 (PDT)
Message-ID: <53B216C5.8020503@codeaurora.org>
Date: Mon, 30 Jun 2014 19:02:45 -0700
From: Laura Abbott <lauraa@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [RFC] CMA page migration failure due to buffers on bh_lru
References: <53A8D092.4040801@lge.com> <xa1td2dvmznq.fsf@mina86.com> <53ACAB82.6020201@lge.com> <53B06DD0.8030106@codeaurora.org> <53B209BA.8010106@lge.com>
In-Reply-To: <53B209BA.8010106@lge.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gioh Kim <gioh.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@suse.de>, =?UTF-8?B?7J206rG07Zi4?= <gunho.lee@lge.com>, Hugh Dickins <hughd@google.com>

On 6/30/2014 6:07 PM, Gioh Kim wrote:
> Hi,Laura.
> 
> I have a question.
> 
> Does the __evict_bh_lru() not need bh_lru_lock()?
> The get_cpu_var() has already preenpt_disable() and can prevent other thread.
> But get_cpu_var cannot prevent IRQ context such like page-fault.
> I think if a page-fault occured and a file is read in IRQ context it can change cpu-lru.
> 
> Is my concern correct?
> 
> 

__evict_bh_lru is called via on_each_cpu_cond which I believe will disable irqs.
I based the code on the existing invalidate_bh_lru which did not take the bh_lru_lock
either. It's possible I missed something though.

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
