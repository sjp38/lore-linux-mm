Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5D7B7C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 11:36:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 192E920854
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 11:36:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 192E920854
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7B3218E0003; Thu, 14 Mar 2019 07:36:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 764248E0001; Thu, 14 Mar 2019 07:36:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 67B7F8E0003; Thu, 14 Mar 2019 07:36:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0DDC58E0001
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 07:36:29 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id x47so2245795eda.8
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 04:36:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=nNuB/lRhH+v/iWPhGCR283/x9HqpybB72FyVA0YDAaM=;
        b=rSZeVkYoDK0mtrLiy4QWCPBfdi+iAt0EwFCWfibtbvujuyEohBzsntHk7X5XGcwlxc
         MKrc5NE0liHGtcHD+ObNq2Gbo/j1iCWOfQzsRzHBzm1J5N6JyaMFT3cen4AEKfznvtqK
         W35/4vVJ0HdY8YUXAXmFxaCKHoPdn1gGP7KzEVh251p5b4Xf+YlyiXK1uehaUgsSgqsu
         X5yxz76z/ejcxKDVgxvwH5sPGcgfdx5SXATy3IRi03a1+LquldmjkbGGwwOCkeFnv2X3
         9kN7vfz0xY6fSaFOQHzECSQOSvyVJzAik5uIJYQsQ5oQN70Q30xU3/j1n+zQOa2AFQ2H
         kYiQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Gm-Message-State: APjAAAUhlVmQL1k8LBD1q/izVwK0ShHbp8RKaqPHMeRngGlIoS4dxG1b
	nb++FPmow1N/vAeJQO4BoC7X3pPxCziwxU51n8+2QnzzWIUqtoB0xPINFtw3inM5a3kWcsETscN
	MD0shoXwfDdr+rlnW0orizEXfxNmfRZ5dLCQ6zTbwhn1wIBuMpbCxxvOMiBTrEJ81HQ==
X-Received: by 2002:a50:89bc:: with SMTP id g57mr10813908edg.89.1552563388567;
        Thu, 14 Mar 2019 04:36:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzukouqLWfeaZ30oLKUYR9guMbqOxIZmxeLryHkiWah/GcUBMvrsWWV4Wefm4y2noej+/6A
X-Received: by 2002:a50:89bc:: with SMTP id g57mr10813858edg.89.1552563387478;
        Thu, 14 Mar 2019 04:36:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552563387; cv=none;
        d=google.com; s=arc-20160816;
        b=GMfSWU13ExowaY7ZHvjKzt3bDlL0zx07QNgp0cSiVTwcs6UOxJQSWgpXvZSOHhSgAe
         VLFrlS3VR4KFm5fHdLjR/swxtwdjt7yuxsjcdNoEBZC5lxG8pKBLZUIbjCPD+L/cNVeW
         mGLrQ8wGel62cDdwkN1NLHidfOL96FgLrSui9LhVs9Bcz1o07jVm7G+EGWiq+/lAwvFQ
         iRqHGp//PSwg4k+I855POeToGDgeLRlhgTYcw0mLEplvt1EdyeRUgk6o+QMQhObD+cQ/
         xmxf+/K6k9p4iyZHcskBPHVlb3xPYQbVYZNJ6Kwen6S17AWYv3v7QmHBoFnpjW7rJvhU
         faWA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=nNuB/lRhH+v/iWPhGCR283/x9HqpybB72FyVA0YDAaM=;
        b=IhgIpo4dxpoDcsBKre9mlNMLIwuKC7ndKyXhe7gwrMamHjVt3NNOM0T33/U7u4xGNQ
         zufyIR8OLXiGcKZcsajxZCm1cPEl/0by1IhLtpNTZkmvvDro4Ol+bD4mWWd0WqirMu+Q
         I2kTMP1HAFmngh7TZMlFE7Qt3iKrdJlWudEsPBMKI9uy20ROcMCxveHCwAZZ+s4BAAgG
         +FUUdYUYveRWus5OQkyicDMEKWYg2hUsUOS3jGebA89Dx68r4rGfxp0TmmjfZT5GlqCU
         p380266n7mp+ReRXXGigSakqB0YLDwLYzhhXCQL12XpBIx2JUD73lzF2LMIRvKfAcSxI
         MASA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 90si1848680edr.146.2019.03.14.04.36.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Mar 2019 04:36:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id DF13CAE5D;
	Thu, 14 Mar 2019 11:36:26 +0000 (UTC)
Date: Thu, 14 Mar 2019 12:36:26 +0100
From: Michal Hocko <mhocko@suse.com>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	Takashi Iwai <tiwai@suse.de>
Subject: Re: [PATCH v2] mm, page_alloc: disallow __GFP_COMP in
 alloc_pages_exact()
Message-ID: <20190314113626.GJ7473@dhcp22.suse.cz>
References: <20190314093944.19406-1-vbabka@suse.cz>
 <20190314094249.19606-1-vbabka@suse.cz>
 <20190314101526.GH7473@dhcp22.suse.cz>
 <1dc997a3-7573-7bd5-9ce6-3bfbf77d1194@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1dc997a3-7573-7bd5-9ce6-3bfbf77d1194@suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 14-03-19 11:30:03, Vlastimil Babka wrote:
> On 3/14/19 11:15 AM, Michal Hocko wrote:
> > On Thu 14-03-19 10:42:49, Vlastimil Babka wrote:
> >> alloc_pages_exact*() allocates a page of sufficient order and then splits it
> >> to return only the number of pages requested. That makes it incompatible with
> >> __GFP_COMP, because compound pages cannot be split.
> >> 
> >> As shown by [1] things may silently work until the requested size (possibly
> >> depending on user) stops being power of two. Then for CONFIG_DEBUG_VM, BUG_ON()
> >> triggers in split_page(). Without CONFIG_DEBUG_VM, consequences are unclear.
> >> 
> >> There are several options here, none of them great:
> >> 
> >> 1) Don't do the spliting when __GFP_COMP is passed, and return the whole
> >> compound page. However if caller then returns it via free_pages_exact(),
> >> that will be unexpected and the freeing actions there will be wrong.
> >> 
> >> 2) Warn and remove __GFP_COMP from the flags. But the caller wanted it, so
> >> things may break later somewhere.
> >> 
> >> 3) Warn and return NULL. However NULL may be unexpected, especially for
> >> small sizes.
> >> 
> >> This patch picks option 3, as it's best defined.
> > 
> > The question is whether callers of alloc_pages_exact do have any
> > fallback because if they don't then this is forcing an always fail path
> > and I strongly suspect this is not really what users want. I would
> > rather go with 2) because "callers wanted it" is much less probable than
> > "caller is simply confused and more gfp flags is surely better than
> > fewer".
> 
> I initially went with 2 as well, as you can see from v1 :) but then I looked at
> the commit [2] mentioned in [1] and I think ALSA legitimaly uses __GFP_COMP so
> that the pages are then mapped to userspace. Breaking that didn't seem good.

It used the flag legitimately before because they were allocating
compound pages but now they don't so this is just a conversion bug.
Why should we screw up the helper for that reason? Or put in other words
why a silent fix up adds any risk?

> The point is that with the warning in place, A developer will immediately know
> that they did something wrong, regardless if the size is power-of-two or not.
> But yeah, if it's adding of __GFP_COMP that is not deterministic, a bug can
> still sit silently for a while.
> 
> But maybe we could go with 1) if free_pages_exact() is also adjusted to check
> for CompoundPage and free it properly?

I dunno, it sounds like it adds even more confusion.

> >> [1] https://lore.kernel.org/lkml/20181126002805.GI18977@shao2-debian/T/#u
> 
> [2]
> https://git.kernel.org/pub/scm/linux/kernel/git/tiwai/sound.git/commit/?id=3a6d1980fe96dbbfe3ae58db0048867f5319cdbf
-- 
Michal Hocko
SUSE Labs

