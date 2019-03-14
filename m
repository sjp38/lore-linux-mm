Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 97625C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 20:13:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5AB5B217F5
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 20:13:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5AB5B217F5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D6F346B0003; Thu, 14 Mar 2019 16:13:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CF3EF6B0005; Thu, 14 Mar 2019 16:13:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B94EC6B0006; Thu, 14 Mar 2019 16:13:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 59CD66B0003
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 16:13:28 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id x13so2871500edq.11
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 13:13:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date
         :message-id:from:to:cc:subject:in-reply-to:references:user-agent
         :mime-version;
        bh=prHkqXO6YuA2dxZR74X4p5uwdoPRogtn2QFUAoTfEbY=;
        b=FwQxPSkhvKMNV4OhBJAYJ0qBjtMT0NigMm7pl/Ls0gcB/xrTfgpQI+NXiYiccsZ/44
         prQkrplmGjF4qq6uCN4HfV5CUkhyFbVmVWKgnqic9xEk+xA53x641kAKjJor/9lXJ2Ny
         wXstN+ioC9is+aObBNlsB82HjZmhnsqEG7Yi12d3LsBQXuScCEqXJXDBHmHULPmN45gG
         y8Lkwip8fs1wKgXgeGjUSjUV8ij6QlWYI3F5/GqfC5jRMEuCpfUX4XgqkJxvWRQnNWXS
         3jW2xb98FHSWSWq5M6rbGp00tSfccH5m1LYmVlA0CGH/Vn6+YPgNqV8UmFXGlUJV3Npz
         8KIw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of tiwai@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=tiwai@suse.de
X-Gm-Message-State: APjAAAWSHRbA3NgsliFvdf5xwXAnFaYtm0FVVf8/btXmiPkfjKFB2j/Z
	qDEYDKgaeLgELhu67Xc5nPtaN4wOyg7/cDQKeyZw5Xz8znLIzaZIP3pFjXieP6Z1YHjSMvQITb4
	5VtYzutp5+k7BWS7swYdJLJWNuXm1/SlYjQ2uWRRliEnj/8HG3gBsVICD8j3xkpxmow==
X-Received: by 2002:a05:6402:78b:: with SMTP id d11mr161063edy.172.1552594407948;
        Thu, 14 Mar 2019 13:13:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzNtVb2oqVEmXnyV0WnEoKk2UYQmg7qu8YZ0ECI+c9ksNvhmqZhyFQItebkU2hcfTUTWaHU
X-Received: by 2002:a05:6402:78b:: with SMTP id d11mr161022edy.172.1552594406957;
        Thu, 14 Mar 2019 13:13:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552594406; cv=none;
        d=google.com; s=arc-20160816;
        b=U7G7xF2lhhkfvKmgSXnJ1PHaQB9et9KmhzPVL/YE3kuQThzGAdul0gcu7k9Te5UdLR
         eFSjAysFsdqIbnRQ/ZWTn6vImBGi2/AMf9Q7a5ZNUPgpMNH4/arSvTmSXsILYE4f+q9h
         RiUrms0IT6RH/aPXX9fpj/zhR6vdHK5DClkwxZy6VkvqWeKv09ZLSoGHoE6ybbAAP74Q
         q/rHlhOUzRB3DAreAbN+JNAgjQPIc3QhAPzZNKDJn9uIhnxcOS/pVwa9TDksfZDamI7U
         vdbY///Iphxig0pPfG2xfDfgl1TQDGoD6p7kOGW7ncufXxAH2hgeG2o//3gHN2iroZi+
         7D/w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:in-reply-to:subject:cc:to:from
         :message-id:date;
        bh=prHkqXO6YuA2dxZR74X4p5uwdoPRogtn2QFUAoTfEbY=;
        b=hBgCnpcKWgLRea0IVy0D9ZrxjGEmQ6zl8WPUCiu07m1TqVA1fjHp5W480xSvG/64xU
         Iu37q0i6ZyyL4jDB9cvV9YD/8xlZBkVPQes1BNSpdzM2i2PBnnUDC+i3zMLP+f3rdMtP
         FQn+mvaANwCpvGoBeovSxL+ZCXA+60IeE3ARXqqYdf3M4TyZoWNn/Y5Wvge0eNqMeiB7
         REUZUKsNYL2i4tVe0fOI5xrjtZzUfY8w4TaouKgkz88Osj5Hbj3nNVRtMfpcNL6DNYRr
         peufP75X38rJLzrg9Fn6+9b8PWC/NtQg4AvJAy6JvmIT/884P/QYpfWsm54Bp3u0uCQn
         f14w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of tiwai@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=tiwai@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h38si32144ede.377.2019.03.14.13.13.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Mar 2019 13:13:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of tiwai@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of tiwai@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=tiwai@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 28CE6AD2C;
	Thu, 14 Mar 2019 20:13:26 +0000 (UTC)
Date: Thu, 14 Mar 2019 21:13:25 +0100
Message-ID: <s5hk1h15i56.wl-tiwai@suse.de>
From: Takashi Iwai <tiwai@suse.de>
To: Hugh Dickins <hughd@google.com>
Cc: Michal Hocko <mhocko@suse.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	linux-mm@kvack.org,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH v2] mm, page_alloc: disallow __GFP_COMP in alloc_pages_exact()
In-Reply-To: <alpine.LSU.2.11.1903141103590.2119@eggly.anvils>
References: <20190314093944.19406-1-vbabka@suse.cz>
	<20190314094249.19606-1-vbabka@suse.cz>
	<20190314101526.GH7473@dhcp22.suse.cz>
	<1dc997a3-7573-7bd5-9ce6-3bfbf77d1194@suse.cz>
	<20190314113626.GJ7473@dhcp22.suse.cz>
	<s5hd0mtsm84.wl-tiwai@suse.de>
	<20190314120939.GK7473@dhcp22.suse.cz>
	<s5ha7hxsikl.wl-tiwai@suse.de>
	<20190314132933.GL7473@dhcp22.suse.cz>
	<s5h5zslqtyv.wl-tiwai@suse.de>
	<alpine.LSU.2.11.1903141021550.1591@eggly.anvils>
	<s5hpnqt5ob2.wl-tiwai@suse.de>
	<alpine.LSU.2.11.1903141103590.2119@eggly.anvils>
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

On Thu, 14 Mar 2019 19:15:22 +0100,
Hugh Dickins wrote:
> 
> On Thu, 14 Mar 2019, Takashi Iwai wrote:
> > On Thu, 14 Mar 2019 18:37:06 +0100,Hugh Dickins wrote:
> > > On Thu, 14 Mar 2019, Takashi Iwai wrote:
> > > > 
> > > > Hugh, could you confirm whether we still need __GFP_COMP in the sound
> > > > buffer allocations?  FWIW, it's the change introduced by the ancient
> > > > commit f3d48f0373c1.
> > > 
> > > I'm not confident in finding all "the sound buffer allocations".
> > > Where you're using alloc_pages_exact() for them, you do not need
> > > __GFP_COMP, and should not pass it.
> > 
> > It was my fault attempt to convert to alloc_pages_exact() and hitting
> > the incompatibility with __GFP_COMP, so it was reverted in the end.
> > 
> > > But if there are other places
> > > where you use one of those page allocators with an "order" argument
> > > non-zero, and map that buffer into userspace (without any split_page()),
> > > there you would still need the __GFP_COMP - zap_pte_range() and others
> > > do the wrong thing on tail ptes if the non-zero-order page has neither
> > > been set up as compound nor split into zero-order pages.
> > 
> > Hm, what if we allocate the whole pages via alloc_pages_exact() (but
> > without __GFP_COMP)?  Can we mmap them properly to user-space like
> > before, or it won't work as-is?
> 
> Yes, you can map the alloc_pages_exact() pages to user-space as
> before, whether or not it ended up using a whole non-zero-order page:
> alloc_pages_exact() does a split_page(), so the subpages end up all just
> ordinary order-zero pages (and need to be freed individually, which
> free_pages_exact() does for you).

Great, thanks for clarification!


Takashi

