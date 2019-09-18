Return-Path: <SRS0=QF98=XN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=0.4 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 742B1C4CECD
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 01:12:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 123D3206C2
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 01:12:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="uQ0e1qlj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 123D3206C2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 775C56B026F; Tue, 17 Sep 2019 21:12:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7264C6B0270; Tue, 17 Sep 2019 21:12:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5EECC6B0271; Tue, 17 Sep 2019 21:12:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0124.hostedemail.com [216.40.44.124])
	by kanga.kvack.org (Postfix) with ESMTP id 3C6266B026F
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 21:12:06 -0400 (EDT)
Received: from smtpin25.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id DFF1C180AD805
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 01:12:05 +0000 (UTC)
X-FDA: 75946265010.25.doll06_12421a018681d
X-HE-Tag: doll06_12421a018681d
X-Filterd-Recvd-Size: 5338
Received: from mail-pf1-f194.google.com (mail-pf1-f194.google.com [209.85.210.194])
	by imf06.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 01:12:05 +0000 (UTC)
Received: by mail-pf1-f194.google.com with SMTP id q21so3214519pfn.11
        for <linux-mm@kvack.org>; Tue, 17 Sep 2019 18:12:05 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=A6h/rAYj8ixpipAtYZaH/aCKJyb351wYyEtGUwKa5Y4=;
        b=uQ0e1qljpKw2WpqpenUG8vRq+8dsyU1zbtnmGjn0AKq5CQ4tf2zQ78SVMVZyV1S26j
         X3SVmyaw/MnXzqjpkjRWb6EpL03KY9O0Ljp0gUFDNoXkUbUw/GIvIrZi/oHdj1A9rqT7
         pqCMmMjhwcLVUx7HSmiJtfHO5zJtccfEPsSZbl1CewAW4JagMAn3KjLD4s1S33h4jWtW
         PkO4MxnZ4XJIDg9HE8zcGgDIL/zbICYYLdSSbpgfxc4G1V6JzAnlUwXKpdT7MFCUr+BZ
         nT3YcR8YgoD3NB7KZHhrdGBzpuCOC8VrTWGUe6dJaWEyA7TUtng9eNjrdBVmvwxLfDot
         Ysqw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:date:from:to:cc:subject:message-id
         :references:mime-version:content-disposition:in-reply-to:user-agent;
        bh=A6h/rAYj8ixpipAtYZaH/aCKJyb351wYyEtGUwKa5Y4=;
        b=HVpXtB5sQchVWf2uSsxHpisQglz+OyZg1vY9GMsrRgA1gA6trKN12L0Aji+9Mj8lww
         SO0vR9Y1VfLOGQyhpRW+EQMKgn9Q/BfF0SAkJ8/r8ImynX1HZo9uDk4+Ppasn1VDL8XP
         ASckEJFNsJa2yE0jamA9fcgBWq63pd9c652+k3K2S9dJ+KIwNnH0U5GqvLL7nUW97EhK
         VUSA1Eho8WRreHuIAvJ6enqa4Oa57JYNYm/DXRCEWkJrJvUNZ7BOmK1jxj6uXt+LT2QJ
         4MZnjqEVm/xtTGtMrUcWbEiSxzF+NwFG2wB0Q9ULi/n42u/HGQkShbAPbt0rjZ56js0f
         JWaA==
X-Gm-Message-State: APjAAAVpzpCZxrlAYV9nxC+CglyGpRusa3RZlaCgEF7fHqwbh5weG+5+
	580iQODFEbXsMWGHJU+l4S0=
X-Google-Smtp-Source: APXvYqwPYKW/v/nayDnUWmpyvt1/nrtpHtIMbFhGkKh9+DFMevq7rIDjI1MXbl1EZ+ADqYlzYRPozA==
X-Received: by 2002:a17:90a:c706:: with SMTP id o6mr1039819pjt.56.1568769123957;
        Tue, 17 Sep 2019 18:12:03 -0700 (PDT)
Received: from google.com ([2620:15c:211:1:3e01:2939:5992:52da])
        by smtp.gmail.com with ESMTPSA id r30sm4966230pfl.42.2019.09.17.18.12.02
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 17 Sep 2019 18:12:02 -0700 (PDT)
Date: Tue, 17 Sep 2019 18:12:00 -0700
From: Minchan Kim <minchan@kernel.org>
To: Vinayak Menon <vinmenon@codeaurora.org>
Cc: linux-mm@kvack.org
Subject: Re: [PATCH] mm: fix the race between swapin_readahead and
 SWP_SYNCHRONOUS_IO path
Message-ID: <20190918011200.GA159757@google.com>
References: <1567169011-4748-1-git-send-email-vinmenon@codeaurora.org>
 <20190909232613.GA39783@google.com>
 <9df3bb51-2094-c849-8171-dce6784e1e70@codeaurora.org>
 <20190910175116.GB39783@google.com>
 <c7fbc609-0bb0-bffd-8b1f-c2588c89bfd2@codeaurora.org>
 <20190912171400.GA119788@google.com>
 <3a500b81-71bb-54bd-9f2f-ab89ee723879@codeaurora.org>
 <20190916200555.GA254094@google.com>
 <4788d556-1b53-8d3e-121c-de2c286bac43@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4788d556-1b53-8d3e-121c-de2c286bac43@codeaurora.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 17, 2019 at 11:08:49AM +0530, Vinayak Menon wrote:
> 
> On 9/17/2019 1:35 AM, Minchan Kim wrote:
> > Hi Vinayak,
> >
> > On Fri, Sep 13, 2019 at 02:35:41PM +0530, Vinayak Menon wrote:
> >> On 9/12/2019 10:44 PM, Minchan Kim wrote:
> >>> Hi Vinayak,
> >>>
> >>> On Wed, Sep 11, 2019 at 03:37:23PM +0530, Vinayak Menon wrote:
> >>>
> >>> < snip >
> >>>
> >>>>>> Can swapcache check be done like below, before taking the SWP_SYNCHRONOUS_IO path, as an alternative ?
> >>>>> With your approach, what prevent below scenario?
> >>>>>
> >>>>> A                                                       B
> >>>>>
> >>>>>                                             do_swap_page
> >>>>>                                             SWP_SYNCHRONOUS_IO && __swap_count == 1
> >>>> As shrink_page_list is picking the page from LRU and B is trying to read from swap simultaneously, I assume someone had read
> >>>>
> >>>> the page from swap prior to B, when its swap_count was say 2 (for it to be reclaimed by shrink_page_list now)
> >>> It could happen after B saw __swap_count == 1. Think about forking new process.
> >>> In that case, swap_count is 2 and the forked process will access the page(it
> >>> ends up freeing zram slot but the page would be swap cache. However, B process
> >>> doesn't know it).
> >>
> >> Okay, so when B has read __swap_count == 1, it means that it has taken down_read on mmap_sem in fault path
> >>
> >> already. This means fork will not be able to proceed which needs to have down_write on parent's mmap_sem ?
> >>
> > You are exactly right. However, I still believe better option to solve
> > the issue is to check swap_count and delte only if swap_count == 1
> > in swap_slot_free_notify because it's zram specific issue and more safe
> > without depending other lock scheme.
> 
> 
> Sure. Let me know if you want me to post a patch for that.
> 

Please post a patch.
Thanks, Vinayak!

