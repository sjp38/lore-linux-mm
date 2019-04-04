Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5B993C10F0E
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 11:58:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 145B72082E
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 11:58:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 145B72082E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A04B76B0005; Thu,  4 Apr 2019 07:58:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9B4C46B0006; Thu,  4 Apr 2019 07:58:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8A3B66B0007; Thu,  4 Apr 2019 07:58:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3B57F6B0005
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 07:58:21 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id f2so1266345edv.15
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 04:58:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=f/Hp9t9XbVD5bSZKUK76GFPnShqv18BolclV2d36SZI=;
        b=n5b4w74ojG3Pm9TaGIN+y6vP1c14JDpD32jiBvo4SBZKa1h0iu2rdwnDA7HQBAoZJQ
         S1KbHYOh9voZz70VMROkHT6Q40dShOk1n6xT9zdWf5WBxSzMysseI3R1mnU8/8vZdN4U
         LpVbeE9C2ZOrg0RjOPOtbBRJikay4RnS2KmY+WPYZ0P0mA/8V/NjqAXLVCxRjy2LQmbZ
         HK3r028sniOTUJZ9i691h2UpmIj28YFrdqHc7oKnYu4G0ltcR931ZEeYl+adZBSR0O4n
         Ll7AOgY5dkT+8ornTPiBCG5a2row5Yxv2aNZ7sGrp0llO0F0MbAkz2uCFlOk71EbqBOn
         FmCw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAWXt2AwX9GG13PWsaz1wvOjh4svJrfeeseUEb1WSwJEy8y1qIDX
	YKSjuO/i8HsHf/oGO8h5gg57vY8Cc89XguRmB6PLhtJsiQWR57WeeusjdzVuXow1OQntrtduz1v
	mb4coKcgCxjBp+B1IqNLxwONiz4Q6tOgQBqDVbhffEiA44ZUA/aZ1hEU4zeF5/BO0bA==
X-Received: by 2002:a50:9b56:: with SMTP id a22mr3607750edj.22.1554379100789;
        Thu, 04 Apr 2019 04:58:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxQn3Ud4y6edKig7aWxkb+um7vV8MdyPf6KYBAvRtGlDF6oMqOtoC9Kz4xr1JkNwFu8g0eS
X-Received: by 2002:a50:9b56:: with SMTP id a22mr3607687edj.22.1554379099734;
        Thu, 04 Apr 2019 04:58:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554379099; cv=none;
        d=google.com; s=arc-20160816;
        b=iXwtM1G01tGAhIL/HeDO6SYAs5JJtH3F+B4HI4UqqAtMMabbx2Ah+YZ7ew9VLySrsz
         DnoJHVpY9Hg4iPVyh61i/xWI9rPGV3onqLeTa9X6F8aEsMclB2Xp2BfX6s0/LLkkjWLm
         oKu7zpcGv1VpMAdX0kc/lO10BUoYaCFC/R+8UUYasVmYvwe+cpq7Z1AMwfKVh9BaKUfg
         nxN2EErjhdJGZYOZyZvLZfKBTQTgNLDGtNLWqdRPs9Puln+DIHKQVNGm1Z4Cdo//jFoz
         w7QxYUMPcgVaVX7ooAVYfGZK1oTNkS+wS3kBAsKAoJeNXfU4WK71hubqm1izBE87ZX/t
         1A0A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=f/Hp9t9XbVD5bSZKUK76GFPnShqv18BolclV2d36SZI=;
        b=x86BlBFXvGK2cCT6c56Nc08yR2hqnqI89BXOXUsKPMLKNEynrAe4Vcp0tHqFc/p6VQ
         sU3H7iEyhbpxzo86bsFPtC/pv99oRmmTtb4gQLaoZu/YzqmTvTmwmG6HukZ0h8A6UZu7
         iR+jomKNoN+A+wnWbkfUytHwrGHRAHFi/Nwi8Ghn1WyAb7P0VWUbAmVqeBGl4KEcI8Kt
         m2UMn1jpUQFb95o28bEIhjOeXzJsgbOCCM1rkh9ii+ql7TZ2ZI498OyvIWgLNa4K1972
         hDfYAe7FqtKjTBisYD8GZMf6evY9c7uIKlNwY995x6Fu9KVOzJIkKUTCov1DV2uaoRNS
         oWUQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (charybdis-ext.suse.de. [195.135.221.2])
        by mx.google.com with ESMTP id z17si2831435eju.305.2019.04.04.04.58.19
        for <linux-mm@kvack.org>;
        Thu, 04 Apr 2019 04:58:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) client-ip=195.135.221.2;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id BC97B4812; Thu,  4 Apr 2019 13:58:18 +0200 (CEST)
Date: Thu, 4 Apr 2019 13:58:18 +0200
From: Oscar Salvador <osalvador@suse.de>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: Robin Murphy <robin.murphy@arm.com>, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
	akpm@linux-foundation.org, will.deacon@arm.com,
	catalin.marinas@arm.com, mhocko@suse.com,
	mgorman@techsingularity.net, james.morse@arm.com,
	mark.rutland@arm.com, cpandya@codeaurora.org, arunks@codeaurora.org,
	dan.j.williams@intel.com, logang@deltatee.com,
	pasha.tatashin@oracle.com, david@redhat.com, cai@lca.pw,
	Steven Price <steven.price@arm.com>
Subject: Re: [PATCH 2/6] arm64/mm: Enable memory hot remove
Message-ID: <20190404115815.gzk3sgg34eofyxfv@d104.suse.de>
References: <1554265806-11501-1-git-send-email-anshuman.khandual@arm.com>
 <1554265806-11501-3-git-send-email-anshuman.khandual@arm.com>
 <ed4ceac4-b92c-47f4-33b0-ed1d0833b40d@arm.com>
 <55278a57-39bc-be27-5999-81d0da37b746@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55278a57-39bc-be27-5999-81d0da37b746@arm.com>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 04, 2019 at 11:09:22AM +0530, Anshuman Khandual wrote:
> > Do these need to be __meminit? AFAICS it's effectively redundant with the containing #ifdef, and removal feels like it's inherently a later-than-init thing anyway.
> 
> I was confused here a bit but even X86 does exactly the same. All these functions
> are still labeled __meminit and all wrapped under CONFIG_MEMORY_HOTPLUG. Is there
> any concern to have __meminit here ?

We do not really need it as long as the code is within #ifdef CONFIG_MEMORY_HOTPLUG.
__meminit is being used when functions that are going to be need for hotplug need
to stay around.

/* Used for MEMORY_HOTPLUG */
#define __meminit        __section(.meminit.text) __cold notrace \
                                                  __latent_entropy

#if defined(CONFIG_MEMORY_HOTPLUG)
#define MEM_KEEP(sec)    *(.mem##sec)
#define MEM_DISCARD(sec)
#else
#define MEM_KEEP(sec)
#define MEM_DISCARD(sec) *(.mem##sec)
#endif

So it is kind of redundant to have both.
I will clean it up when reposting [1] and [2].

[1] https://patchwork.kernel.org/patch/10875019/
[2] https://patchwork.kernel.org/patch/10875021/

-- 
Oscar Salvador
SUSE L3

