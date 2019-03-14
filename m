Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 86553C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 11:56:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4D54420693
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 11:56:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4D54420693
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DE6218E0003; Thu, 14 Mar 2019 07:56:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D6E268E0001; Thu, 14 Mar 2019 07:56:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C0FBF8E0003; Thu, 14 Mar 2019 07:56:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 605038E0001
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 07:56:45 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id k21so2301473eds.19
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 04:56:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date
         :message-id:from:to:cc:subject:in-reply-to:references:user-agent
         :mime-version;
        bh=bFJ5aTFNYCQWq+J9DCkuX9kJ+qtED0Go9ByLFOTaVA0=;
        b=enp6ePXKw86fPZYW3HRvWwD7YZeUgdn+dGm2DY2DGVTywovqFQFlZZikDVMt2nXiRa
         BmJD7XZ0Jk1KloJR6+bFDvKuYnt1g7VahHePpXNYQOlIu9SkG7ActkzDX8YOuFLpKpRA
         1TaTe2NDhDBwpUxxUVQwi+v8HQz9kxGKVFXkMo25mZBl93yYdjhDfdlXS3jeBGU6PRGb
         j03rE1B9Zd/qrUQAm0ogk3XGkk4lvkSyK3YNOgBx0USUkr1j61mx3fHKg8FPQgp6Zk1i
         TD+wVqWkTsFrxTcMnpixy8mhEXmw/p7tz32ijELngBuoptUQzq7ZGnO6C3FfQSRP09Yd
         HAUw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of tiwai@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=tiwai@suse.de
X-Gm-Message-State: APjAAAWJNfj2ah9z4So1H2AEKr0wyrPzgVod344HcMW7uysM2RTRzI4M
	ucyZXC4J4nCcgzn2H/RU9kHvSMhKaI1giHyLAgbUkTfw+NXVhT6uZOVTQzTAbKyA2VmLtmg1O3O
	5K6WelZpaLUzMSg44Rn/qIQ2ol/s8BDoAJ6AXVQhFfsNlKS9IMdQdmWYvejbhO9Sbuw==
X-Received: by 2002:a17:906:28c9:: with SMTP id p9mr32156220ejd.43.1552564604963;
        Thu, 14 Mar 2019 04:56:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzPiIMr2S+rG1lDc+neuG48L2Nclci0VJIdizDZSqOxMKgEFLQ6vviBIqs0guBUARAXamhA
X-Received: by 2002:a17:906:28c9:: with SMTP id p9mr32156170ejd.43.1552564603795;
        Thu, 14 Mar 2019 04:56:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552564603; cv=none;
        d=google.com; s=arc-20160816;
        b=ySkb1B0jmy2niuqUrLbLgw0hYSp+VcmsZfDz8rq4AAjogJ5UXuf2Jx3kxMuvWL+v64
         +lIxzh1f1/ng3xCprsyMA5tp5YaYPKZAFq86khq1f5MaiV2CmgG/DouMoMqhp4CFYIIs
         1YQjtewSExcOKU8JWq2eiOoAPp7VFNCtK5+sB5KgcccBtnsWn+JaejtBQB0TjIlCm7Cf
         MgFflTiDYWhs58t9QxAcCEp3Twn3F1yPIgybSPDNV3+2yC0ESmvseiDXMVtOaCqo7fWk
         L1CwOUfGu9ZDbGJSUkOsDPNWcMZEfLIsfAijtLbsHaRqBir06OjJdew7bRCqNLaX8sbf
         rc2Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:in-reply-to:subject:cc:to:from
         :message-id:date;
        bh=bFJ5aTFNYCQWq+J9DCkuX9kJ+qtED0Go9ByLFOTaVA0=;
        b=jRyhRQSWsf0B8d63JYug4M8QUg2YYGEkxDS5zS5K/1ZllD1Hz8OjGu6Yj8B/2bmnuh
         9qO+FvfqiKscTrI1PLgwfcNZKcUsL0Nv3YsSVAGq8xR5fcv4GZtzcp5IiLD3g+V1yz6q
         Lp8wFTqj0OejcjH38WKg6W5tCPsmwy6Vp7/OYpvP7ai7joBw8RIINHFfnydJEQhqXyC9
         3PMeLgxSfwS4V806ImhDg6YWdDfKLXE/uoFOPyUIjUb+jZxQhS2vmaxlK9zymYqvsK3+
         5N3P4b/Wq4h9wagGb/ppdyVjBgRQTy66zQI34UzJ2wbMcduyKvRN5xNEuwDf0tfz27Bz
         s1/g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of tiwai@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=tiwai@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c35si1878294edb.127.2019.03.14.04.56.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Mar 2019 04:56:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of tiwai@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of tiwai@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=tiwai@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 4C173AE5D;
	Thu, 14 Mar 2019 11:56:43 +0000 (UTC)
Date: Thu, 14 Mar 2019 12:56:43 +0100
Message-ID: <s5hd0mtsm84.wl-tiwai@suse.de>
From: Takashi Iwai <tiwai@suse.de>
To: Michal Hocko <mhocko@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>,
	linux-mm@kvack.org,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	Takashi Iwai <tiwai@suse.de>
Subject: Re: [PATCH v2] mm, page_alloc: disallow __GFP_COMP in alloc_pages_exact()
In-Reply-To: <20190314113626.GJ7473@dhcp22.suse.cz>
References: <20190314093944.19406-1-vbabka@suse.cz>
	<20190314094249.19606-1-vbabka@suse.cz>
	<20190314101526.GH7473@dhcp22.suse.cz>
	<1dc997a3-7573-7bd5-9ce6-3bfbf77d1194@suse.cz>
	<20190314113626.GJ7473@dhcp22.suse.cz>
User-Agent: Wanderlust/2.15.9 (Almost Unreal) SEMI/1.14.6 (Maruoka)
 FLIM/1.14.9 (=?UTF-8?B?R29qxY0=?=) APEL/10.8 Emacs/25.3
 (x86_64-suse-linux-gnu) MULE/6.0 (HANACHIRUSATO)
MIME-Version: 1.0 (generated by SEMI 1.14.6 - "Maruoka")
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 14 Mar 2019 12:36:26 +0100,
Michal Hocko wrote:
> 
> On Thu 14-03-19 11:30:03, Vlastimil Babka wrote:
> > On 3/14/19 11:15 AM, Michal Hocko wrote:
> > > On Thu 14-03-19 10:42:49, Vlastimil Babka wrote:
> > >> alloc_pages_exact*() allocates a page of sufficient order and then splits it
> > >> to return only the number of pages requested. That makes it incompatible with
> > >> __GFP_COMP, because compound pages cannot be split.
> > >> 
> > >> As shown by [1] things may silently work until the requested size (possibly
> > >> depending on user) stops being power of two. Then for CONFIG_DEBUG_VM, BUG_ON()
> > >> triggers in split_page(). Without CONFIG_DEBUG_VM, consequences are unclear.
> > >> 
> > >> There are several options here, none of them great:
> > >> 
> > >> 1) Don't do the spliting when __GFP_COMP is passed, and return the whole
> > >> compound page. However if caller then returns it via free_pages_exact(),
> > >> that will be unexpected and the freeing actions there will be wrong.
> > >> 
> > >> 2) Warn and remove __GFP_COMP from the flags. But the caller wanted it, so
> > >> things may break later somewhere.
> > >> 
> > >> 3) Warn and return NULL. However NULL may be unexpected, especially for
> > >> small sizes.
> > >> 
> > >> This patch picks option 3, as it's best defined.
> > > 
> > > The question is whether callers of alloc_pages_exact do have any
> > > fallback because if they don't then this is forcing an always fail path
> > > and I strongly suspect this is not really what users want. I would
> > > rather go with 2) because "callers wanted it" is much less probable than
> > > "caller is simply confused and more gfp flags is surely better than
> > > fewer".
> > 
> > I initially went with 2 as well, as you can see from v1 :) but then I looked at
> > the commit [2] mentioned in [1] and I think ALSA legitimaly uses __GFP_COMP so
> > that the pages are then mapped to userspace. Breaking that didn't seem good.
> 
> It used the flag legitimately before because they were allocating
> compound pages but now they don't so this is just a conversion bug.

We still use __GFP_COMP for allocation of the sound buffers that are
also mmapped to user-space.  The mentioned commit above [2] was
reverted later.

But honestly speaking, I'm not sure whether we still need the compound
pages.  The change was introduced long time ago (commit f3d48f0373c1
in 2005).  Is it superfluous nowadays...?

> Why should we screw up the helper for that reason? Or put in other words
> why a silent fix up adds any risk?

IMO, it's good to catch the incompatible usage as early as possible,
so that others won't hit the same failure again like I did.  There
aren't so many users of __GFP_COMP in the whole tree, after all.


thanks,

Takashi

> > The point is that with the warning in place, A developer will immediately know
> > that they did something wrong, regardless if the size is power-of-two or not.
> > But yeah, if it's adding of __GFP_COMP that is not deterministic, a bug can
> > still sit silently for a while.
> > 
> > But maybe we could go with 1) if free_pages_exact() is also adjusted to check
> > for CompoundPage and free it properly?
> 
> I dunno, it sounds like it adds even more confusion.
> 
> > >> [1] https://lore.kernel.org/lkml/20181126002805.GI18977@shao2-debian/T/#u
> > 
> > [2]
> > https://git.kernel.org/pub/scm/linux/kernel/git/tiwai/sound.git/commit/?id=3a6d1980fe96dbbfe3ae58db0048867f5319cdbf
> -- 
> Michal Hocko
> SUSE Labs
> 

