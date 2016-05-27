Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id BCF566B007E
	for <linux-mm@kvack.org>; Fri, 27 May 2016 16:30:02 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id b124so214180376pfb.1
        for <linux-mm@kvack.org>; Fri, 27 May 2016 13:30:02 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id w13si30520214pas.206.2016.05.27.13.30.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 May 2016 13:30:01 -0700 (PDT)
Date: Fri, 27 May 2016 13:30:00 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: check the return value of lookup_page_ext for all
 call sites
Message-Id: <20160527133000.84a887b7ce8d2e6387145b4d@linux-foundation.org>
In-Reply-To: <ab9cf30c-4979-07af-6732-e647078ef579@linaro.org>
References: <1464023768-31025-1-git-send-email-yang.shi@linaro.org>
	<20160524025811.GA29094@bbox>
	<20160526003719.GB9661@bbox>
	<8ae0197c-47b7-e5d2-20c3-eb9d01e6b65c@linaro.org>
	<20160527130246.4adb78f29e15d19fae80419a@linux-foundation.org>
	<ab9cf30c-4979-07af-6732-e647078ef579@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Shi, Yang" <yang.shi@linaro.org>
Cc: Minchan Kim <minchan@kernel.org>, iamjoonsoo.kim@lge.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org

On Fri, 27 May 2016 13:17:19 -0700 "Shi, Yang" <yang.shi@linaro.org> wrote:

> >> Actually, I think the #ifdef should be removed if lookup_page_ext() is
> >> possible to return NULL. It sounds not make sense returning NULL only
> >> when DEBUG_VM is enabled. It should return NULL no matter what debug
> >> config is selected. If Joonsoo agrees with me I'm going to come up with
> >> a patch to fix it.
> >>
> >
> > I've lost the plot here.  What is the status of this patch?
> >
> > Latest version:
> 
> Yes, this is the latest version. We are discussing about some future 
> optimization.
> 
> And, Minchan Kim pointed out a possible race condition which exists even 
> before this patch. I proposed a quick fix, as long as they are happy to 
> the fix, I will post it to the mailing list.

OK, thanks - I've moved it into the for-Linus-next-week queue.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
