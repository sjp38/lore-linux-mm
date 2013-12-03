Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id B90296B0031
	for <linux-mm@kvack.org>; Mon,  2 Dec 2013 23:59:47 -0500 (EST)
Received: by mail-pd0-f173.google.com with SMTP id p10so19533941pdj.32
        for <linux-mm@kvack.org>; Mon, 02 Dec 2013 20:59:47 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id nu5si10276770pbc.268.2013.12.02.20.59.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Dec 2013 20:59:46 -0800 (PST)
Message-ID: <529D653F.3090401@codeaurora.org>
Date: Mon, 02 Dec 2013 20:59:43 -0800
From: Laura Abbott <lauraa@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 3/4] mm/vmalloc.c: Allow lowmem to be tracked in vmalloc
References: <1384212412-21236-1-git-send-email-lauraa@codeaurora.org>	<1384212412-21236-4-git-send-email-lauraa@codeaurora.org>	<52850C37.1080506@sr71.net>	<5285A896.3030204@codeaurora.org> <20131126144541.6b16979b77f927f6d945ab60@linux-foundation.org>
In-Reply-To: <20131126144541.6b16979b77f927f6d945ab60@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave@sr71.net>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Neeti Desai <neetid@codeaurora.org>

On 11/26/2013 2:45 PM, Andrew Morton wrote:
> So yes, it would be prudent to be worried about is_vmalloc_addr()
> performance at the outset.
>
> Couldn't is_vmalloc_addr() just be done with a plain old bitmap?  It
> would consume 128kbytes to manage a 4G address space, and 1/8th of a meg
> isn't much.
>

Yes, I came to the same conclusion after realizing I needed something 
similar to fix up proc/kcore.c . I plan to go with the bitmap for the 
next patch version.

Laura

-- 
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
