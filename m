Return-Path: <SRS0=B01V=PM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 154CFC43387
	for <linux-mm@archiver.kernel.org>; Fri,  4 Jan 2019 09:01:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C67132184B
	for <linux-mm@archiver.kernel.org>; Fri,  4 Jan 2019 09:01:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ODsjbh8R"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C67132184B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6A2008E00C8; Fri,  4 Jan 2019 04:01:22 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 650AF8E00AE; Fri,  4 Jan 2019 04:01:22 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5415B8E00C8; Fri,  4 Jan 2019 04:01:22 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2B5898E00AE
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 04:01:22 -0500 (EST)
Received: by mail-io1-f72.google.com with SMTP id q16so16998570ios.1
        for <linux-mm@kvack.org>; Fri, 04 Jan 2019 01:01:22 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=dL7DdFogTaGK/C1f0o7MPX4SYHIrTik8QeCp4BRs48Q=;
        b=X05vN/HIQrLN6iP7O/OUkTF8ZHuHMrgu7X458LiVZqAlI6/WSmEcWh6bEHbdFejb7F
         CpEdcMKt6b7oHfRHLBUjlmLBqm7jHjlNYcgLzRxH06f1WD7FH4+BC+7L5JF9N2CKom7e
         C6Gka8D93VUdEHN9/A+gV8/6V4l8VPo18z1dF5/99dXndhF0wGSiSfXTpFXmkxQYzjtL
         1v4nmI9y/IQfO90JgUTdyURRcE0k47KUzV90xzqx7zPwR0EtwLSWjjsBeJW2UDw0w6xK
         9vtPP+9iyytL0G4jfadarkvWzkUFmNovnTo5wqBlvF42pzf6+yRW7Pc+CpAL9YRQXWLJ
         QWLg==
X-Gm-Message-State: AJcUukdFEsLxlzVF54C7HePomF8P8Kqyaen8eCghsHkpnYUmBrMNAM1C
	iWxRT6Laj3NE/kHoRhsN5ng1+WI8RuEIGEYvYnTUDSP4bHmZ1AdU3X/TSe8x0lECSX8I06NyrCu
	+Mzo470Kv6qbsyn4WTufMYpAjadcmFfvVSqnMGbe881KTqrWWXgkPwKVOu2x+w3YZ50k/Bi6hsx
	Q76/VJ8+VIvYVOmclQBX+RQQ8CcVmTMjiQcZDrkNgA30s0zS2Ur1AqaZ6rC4IXe09Opt1H03HA1
	P60hbIPbOJHWfLZCCpRP1f7+nGPtoDRm+KUqmkMO/yfxWbfL/+ZqkaKJjVG1hwJesP8ngnOqcCS
	n/UlfhsqZkhhbBQWAYdVVQKB9nUxb8iOD/56yZdlc/VdPaZx4jhC6R6EEqfcO6Xt6Ljn9CIjhge
	6
X-Received: by 2002:a6b:cc07:: with SMTP id c7mr16032071iog.136.1546592481924;
        Fri, 04 Jan 2019 01:01:21 -0800 (PST)
X-Received: by 2002:a6b:cc07:: with SMTP id c7mr16032043iog.136.1546592481321;
        Fri, 04 Jan 2019 01:01:21 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546592481; cv=none;
        d=google.com; s=arc-20160816;
        b=GAq6s2jynklhqWQcOBNBbI4HoTpLRQsZh8z5RUErxjBJnAr28AQRdwujd1VVF6D2Pu
         lvfv+il+AKVGM+uxV7TSxceIAdxiqK0xu+a2v40vSW3tOkoA3u+AxP4rPRKu68+knPSU
         AIe2knJzoCXUwiYtCuXNXSHLrAty2p6k29q+4es9Gg76BnxaVByeFNQSE0p5n9TplJsw
         LmvteVIeFsWlSrQxM1mN59dn+PI/4Y3QqD5lMz2hmfYU3soFG4mjFlVlQGjIQfegXS0X
         5vcLmooq9Rz4VDB2tI4wQhdUoqj0AJPpQLcP21Egl77W6xhlyyG8s28VykV8f70WYVAL
         jrRQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=dL7DdFogTaGK/C1f0o7MPX4SYHIrTik8QeCp4BRs48Q=;
        b=Ft2xbacSq4m1M8uqkF2dqQq8wnfrk4vjPcALFlWkrz+neCOEc46RoFv3OySGF25VH1
         N1/0AxK39eyGBIkX+DEuaoa+G0poC3E4rFcY2JRnStxcdDh/gvBSrSwZvoHYM+B0z4wH
         w+ZRuHl3+qUfzVgS/QvHuaIuOruNIbfbqozeWhyJI8NZCURJhuA2p534CQt0IUDlo91q
         FBV0/7FtL6zEC4zU2oo4z0lmTIOqKfVxWyhnT2F/PzK9S+kVjH0aCnfJ+Rh8N9RAO4dr
         Ugd749Yv2gu5cI6vP+0vsMj8UxgphP/mtFdEQYRNsNfEQAr3IOgLOrA859YE8UelesYc
         JXSw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ODsjbh8R;
       spf=pass (google.com: domain of getarunks@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=getarunks@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 64sor14270554ioy.47.2019.01.04.01.01.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 04 Jan 2019 01:01:21 -0800 (PST)
Received-SPF: pass (google.com: domain of getarunks@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ODsjbh8R;
       spf=pass (google.com: domain of getarunks@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=getarunks@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=dL7DdFogTaGK/C1f0o7MPX4SYHIrTik8QeCp4BRs48Q=;
        b=ODsjbh8Rv7doTXP1+40w8VPGhwmlUE1twPhFTk2fJCFTha3TK2nVjCYKLBBWl9iUG7
         AmHF32YJk5uYWqXWOcWd7BLLspWp5OA20Q7mh0KiS6tu2JhVMuoBtn4bTVHqXrCH5a8i
         /vfe/1SRrRZH+58G/FloATrO4meusvfSHFFPMLT4Cxq+q08D4ikrfmcej73+7zZz/1sZ
         KxVwAHDevrPl8Imev9uq89QqLTPKh7Z2uy7olFl1gN2quDGhdXefnmQKG9uLzGC/4CtE
         IXgF9Fy0Do8O2S5EhbUElO1JElsihFAiNPbvYiFrcVBzYc0n9+7SuMiFpRQjpw4/QS3r
         CXRg==
X-Google-Smtp-Source: ALg8bN5YBuk0c2WqfA87Fv5Qch5+e5KSZZVr/UkcHtGZRd8NMfIk0jBhFpk+I8JDLh8CtkSUvcPuk7kcElCuAdOkhcg=
X-Received: by 2002:a5d:8491:: with SMTP id t17mr35528540iom.11.1546592480919;
 Fri, 04 Jan 2019 01:01:20 -0800 (PST)
MIME-Version: 1.0
References: <1541484194-1493-1-git-send-email-arunks@codeaurora.org>
 <20181106140638.GN27423@dhcp22.suse.cz> <542cd3516b54d88d1bffede02c6045b8@codeaurora.org>
 <20181106200823.GT27423@dhcp22.suse.cz> <5e55c6e64a2bfd6eed855ea17a34788b@codeaurora.org>
 <40a4d5154fbd0006fbe55eb68703bb65@codeaurora.org> <20190104085801.GH31793@dhcp22.suse.cz>
In-Reply-To: <20190104085801.GH31793@dhcp22.suse.cz>
From: Arun Sudhilal <getarunks@gmail.com>
Date: Fri, 4 Jan 2019 14:31:09 +0530
Message-ID:
 <CABOM9ZpAEp_BMBcy-ywj0J33CNuMRwNeS9tUainOxRgPOndxfQ@mail.gmail.com>
Subject: Re: [PATCH v6 1/2] memory_hotplug: Free pages as higher order
To: Michal Hocko <mhocko@kernel.org>
Cc: Arun KS <arunks@codeaurora.org>, "arunks.linux" <arunks.linux@gmail.com>, 
	Andrew Morton <akpm@linux-foundation.org>, vbabka@suse.cz, osalvador@suse.de, 
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190104090109.Dq4n6Mc6a9pE21TGriEKKsAsYWXrCE5fRKAyl3IwSLY@z>

On Fri, Jan 4, 2019 at 2:28 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Fri 04-01-19 10:35:58, Arun KS wrote:
> > On 2018-11-07 11:51, Arun KS wrote:
> > > On 2018-11-07 01:38, Michal Hocko wrote:
> > > > On Tue 06-11-18 21:01:29, Arun KS wrote:
> > > > > On 2018-11-06 19:36, Michal Hocko wrote:
> > > > > > On Tue 06-11-18 11:33:13, Arun KS wrote:
> > > > > > > When free pages are done with higher order, time spend on
> > > > > > > coalescing pages by buddy allocator can be reduced. With
> > > > > > > section size of 256MB, hot add latency of a single section
> > > > > > > shows improvement from 50-60 ms to less than 1 ms, hence
> > > > > > > improving the hot add latency by 60%. Modify external
> > > > > > > providers of online callback to align with the change.
> > > > > > >
> > > > > > > This patch modifies totalram_pages, zone->managed_pages and
> > > > > > > totalhigh_pages outside managed_page_count_lock. A follow up
> > > > > > > series will be send to convert these variable to atomic to
> > > > > > > avoid readers potentially seeing a store tear.
> > > > > >
> > > > > > Is there any reason to rush this through rather than wait for counters
> > > > > > conversion first?
> > > > >
> > > > > Sure Michal.
> > > > >
> > > > > Conversion patch, https://patchwork.kernel.org/cover/10657217/
> > > > > is currently
> > > > > incremental to this patch.
> > > >
> > > > The ordering should be other way around. Because as things stand with
> > > > this patch first it is possible to introduce a subtle race prone
> > > > updates. As I've said I am skeptical the race would matter, really,
> > > > but
> > > > there is no real reason to risk for that. Especially when you have the
> > > > other (first) half ready.
> > >
> > > Makes sense. I have rebased the preparatory patch on top of -rc1.
> > > https://patchwork.kernel.org/patch/10670787/
> >
> > Hello Michal,
> >
> > Please review version 7 sent,
> > https://lore.kernel.org/patchwork/patch/1028908/
>
> I believe I have give my Acked-by to this version already, and v7 indeed
> has it. Are there any relevant changes since v6 for me to do the review
> again. If yes you should have dropped the Acked-by.

No Michal. Patch is same. Only difference is this patch is re-based on
top of preparatory patch.
https://patchwork.kernel.org/patch/10670787/

Regards,
Arun

> --
> Michal Hocko
> SUSE Labs

