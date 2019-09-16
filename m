Return-Path: <SRS0=CHX8=XL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=0.4 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 82879C49ED7
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 20:06:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3C1AE20644
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 20:06:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="GVoyQQcE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3C1AE20644
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CB9986B0003; Mon, 16 Sep 2019 16:06:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C6AF06B0006; Mon, 16 Sep 2019 16:06:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B58FD6B0007; Mon, 16 Sep 2019 16:06:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0050.hostedemail.com [216.40.44.50])
	by kanga.kvack.org (Postfix) with ESMTP id 8F6AE6B0003
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 16:06:00 -0400 (EDT)
Received: from smtpin19.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 26D78181AC9BA
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 20:06:00 +0000 (UTC)
X-FDA: 75941864880.19.wine70_34572f870b209
X-HE-Tag: wine70_34572f870b209
X-Filterd-Recvd-Size: 4946
Received: from mail-pg1-f194.google.com (mail-pg1-f194.google.com [209.85.215.194])
	by imf31.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 20:05:59 +0000 (UTC)
Received: by mail-pg1-f194.google.com with SMTP id u72so590481pgb.10
        for <linux-mm@kvack.org>; Mon, 16 Sep 2019 13:05:59 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=jAoHdLmfGoP4H1+y+WGIW1MNymglm7bC36smF+jP66k=;
        b=GVoyQQcEM3ujpX+PRarptkDJZPi8OsofBCdmL1/o1tHkY+m5AuRrFaSQERb+gFMGdX
         YgMi0Vl2BZ/dsvM6XMNHjXhedAdB+ET7x153YYiLDT3sBKKJojKvOTheB0grsQhdyEE7
         TnjcRx9tNdjs0wZRhFPRC52K8PaB2iei0IcYYODO4A1xQWqsfJwkwRe86/ZHPKqkDn4G
         twZvWWLfutiUIgd6/6tzBmAY4FH4TCv7GoCjAXsXHHFkBeQHu2EWwsHAYaui7vELHq2i
         iM97i1C04EiHvo3apNJi6yHak8dWTDAR/5OQxr3ajIJPlOwJLtr/0TCGEK99KaY/e6Ty
         yMpQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:date:from:to:cc:subject:message-id
         :references:mime-version:content-disposition:in-reply-to:user-agent;
        bh=jAoHdLmfGoP4H1+y+WGIW1MNymglm7bC36smF+jP66k=;
        b=ZnkSvbtE72/J1HJCyC+8FVMksOqsvYdRqlIfe9ciQg4X/z+jka6ytIz6xsyRvUIScH
         /8JKzH3PKbfMdS+7prpzB2Xxg7xrI9EM1LkQF5V+LWJMbnAhWGrURQBzVq3CjXfghaAl
         7/erAcUdW2bdLOyrNsDPFLSKafdEHyKXoQjvLMFVN88Q9K5FUscn/IPbWSgK5wMdPipS
         xXYNgsdjqpN6c7Y4nLd/oNy0fVRlk1Rb3TgRHJCljqD4yNClOVRDm+XdIB2iMwEgJGNy
         bjed52S7diU6By6zvDKI/m2Hh08N14NqTDUmsk8JCphg4mWGPFQVvBPb2eJuKr+Pnyzy
         enxw==
X-Gm-Message-State: APjAAAUiCAB0F1O26TLMtAUt31e4S6Rd0ypCJtxeDMggHREqR5HiGq4a
	/KdcV6N1fFBuEufNGcLy6l8=
X-Google-Smtp-Source: APXvYqwsiWoZ3cPMb7sbsUs2sG6Cq98Ms4N4wxnzVs1ll9rWBDMbotE6GnFBB/zDnBB0F32wWJm0Ug==
X-Received: by 2002:a63:9557:: with SMTP id t23mr868514pgn.236.1568664358475;
        Mon, 16 Sep 2019 13:05:58 -0700 (PDT)
Received: from google.com ([2620:15c:211:1:3e01:2939:5992:52da])
        by smtp.gmail.com with ESMTPSA id c35sm32909182pgl.72.2019.09.16.13.05.56
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 16 Sep 2019 13:05:56 -0700 (PDT)
Date: Mon, 16 Sep 2019 13:05:55 -0700
From: Minchan Kim <minchan@kernel.org>
To: Vinayak Menon <vinmenon@codeaurora.org>
Cc: linux-mm@kvack.org
Subject: Re: [PATCH] mm: fix the race between swapin_readahead and
 SWP_SYNCHRONOUS_IO path
Message-ID: <20190916200555.GA254094@google.com>
References: <1567169011-4748-1-git-send-email-vinmenon@codeaurora.org>
 <20190909232613.GA39783@google.com>
 <9df3bb51-2094-c849-8171-dce6784e1e70@codeaurora.org>
 <20190910175116.GB39783@google.com>
 <c7fbc609-0bb0-bffd-8b1f-c2588c89bfd2@codeaurora.org>
 <20190912171400.GA119788@google.com>
 <3a500b81-71bb-54bd-9f2f-ab89ee723879@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3a500b81-71bb-54bd-9f2f-ab89ee723879@codeaurora.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Vinayak,

On Fri, Sep 13, 2019 at 02:35:41PM +0530, Vinayak Menon wrote:
> 
> On 9/12/2019 10:44 PM, Minchan Kim wrote:
> > Hi Vinayak,
> >
> > On Wed, Sep 11, 2019 at 03:37:23PM +0530, Vinayak Menon wrote:
> >
> > < snip >
> >
> >>>> Can swapcache check be done like below, before taking the SWP_SYNCHRONOUS_IO path, as an alternative ?
> >>> With your approach, what prevent below scenario?
> >>>
> >>> A                                                       B
> >>>
> >>>                                             do_swap_page
> >>>                                             SWP_SYNCHRONOUS_IO && __swap_count == 1
> >>
> >> As shrink_page_list is picking the page from LRU and B is trying to read from swap simultaneously, I assume someone had read
> >>
> >> the page from swap prior to B, when its swap_count was say 2 (for it to be reclaimed by shrink_page_list now)
> > It could happen after B saw __swap_count == 1. Think about forking new process.
> > In that case, swap_count is 2 and the forked process will access the page(it
> > ends up freeing zram slot but the page would be swap cache. However, B process
> > doesn't know it).
> 
> 
> Okay, so when B has read __swap_count == 1, it means that it has taken down_read on mmap_sem in fault path
> 
> already. This means fork will not be able to proceed which needs to have down_write on parent's mmap_sem ?
> 

You are exactly right. However, I still believe better option to solve
the issue is to check swap_count and delte only if swap_count == 1
in swap_slot_free_notify because it's zram specific issue and more safe
without depending other lock scheme.

