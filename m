Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1B85BC43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 05:40:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AF2302173C
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 05:40:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="X2QdwSYD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AF2302173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 13D788E0003; Tue, 26 Feb 2019 00:40:19 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0EBAF8E0002; Tue, 26 Feb 2019 00:40:19 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F1CDB8E0003; Tue, 26 Feb 2019 00:40:18 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id BF4058E0002
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 00:40:18 -0500 (EST)
Received: by mail-io1-f71.google.com with SMTP id e1so9512198iod.23
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 21:40:18 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=d2WRTnzkd0HHCIjHVGDZyo2Tadbbej1CTbAbmG5YY9w=;
        b=naYMe5c39JON+N9P/mwCfhMUoULolzBaed9uoYLPi6L0j6LfBWBgcqZgegJYm+W3RK
         KsErv9L0JbW3dw4z2bI9Fug9CFVF10Anktoi2q6y9F4S4w8Gem7YqC3If+YL2tQHTez+
         /Xyl12qZajYoZaRKm/RvFPwihPk3BeEyd4567py0La4QWY7f7zkHPw2kYiT6K+ducpHM
         H3dJAQak+FTm2kd35Dz9UtR8bI9QMNCpYZGPXLR9LqyKVjphcSLD6DpH9aqeQxhEmu4k
         6YB38GHP9/GV7qRZGMv24iP/E7IgUbFNFqzG1M9+B27bxiiCfxNQiH9qx+oqZGJ1OcsI
         p6Lg==
X-Gm-Message-State: APjAAAVCDk/fouVGEVouWK33X/0mdKgutmk8ckeuRCiJEb+dQaKWzqlV
	Rd/fhaIcMhB56rsmy1/nh9PoxfNVvFPlpFduhFSHVdGxxye/jiePZ8JATgryYFRAX+0+Ku+seGT
	BxJ2jPBhETncOoBkonMuQ8clSEzxo2/rkqCUHXQ5jq7rxz4f3O7Lzl24oW7thR+Ldn1xb45eb0h
	dRCtZouA6ptsU4T51i4DQjGLyqKysoyUzDItpdkxUdho3fYHpOMiYKu4fQUHlt9fa7G2fFsYziR
	0YmERfRazZqXej8aDdzBhXNJbyPvQhP+1kfmksFqDh3+TA8LPxeQl09z+DxHTNanKlbsQJ9fCOQ
	3IKAZGwHb09FeXnFeeErtQq1mdsD6YpsW66nUyccWiYWxyAvi9/x5h6NWeaTtcq36Oa7ybZ0+Uy
	d
X-Received: by 2002:a24:1d0:: with SMTP id 199mr187566itk.41.1551159618465;
        Mon, 25 Feb 2019 21:40:18 -0800 (PST)
X-Received: by 2002:a24:1d0:: with SMTP id 199mr187546itk.41.1551159617625;
        Mon, 25 Feb 2019 21:40:17 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551159617; cv=none;
        d=google.com; s=arc-20160816;
        b=JuSSOLwDpaOt1F7Bp/JrX5ogwYHPoZ2RqEeFbWFzlvMEqdjMmlZD6TzCWJp8gCEp/K
         u6gAgGK8EBMM/fV5Fik09HBphKoFOCind3xaVhGIWZMv4G6S5yy7Hf8tHpY7amTvNdqx
         gVuDFxG2ibaLtZsMoiFLbVo4Re7kvhhyGkSBQijFo/bX9XrMooB+2nx/REUgIv44BVjg
         3bZZ0SmCU8XA4qjmHQ5KNimvYTOLHqnl/bEhZsKdQ2b6bBd+BwlVubvE+QqNGWcK4ohz
         VzbwIV3ptbxxCkE4x5Y4gdnBJ0JdkEIBqsKnHv9jdLJ9P1IkdQBBZQkeNnq18qeE3Uy5
         djlA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=d2WRTnzkd0HHCIjHVGDZyo2Tadbbej1CTbAbmG5YY9w=;
        b=BUuerPPZ6LRHQSQUhqp4K2D4mOP3j4NhELOVOyx8ku8NXNWsZh58WYNWEuSuv30Ac9
         hdIj+ZOvcYg+4CZpNLZWJirZOCyt0bLPRZ20PU0sJrIPfvvLr7crTwGJBRpgCaQB8nKW
         Y12lJtHWDYDL2YcBNKgmOfq3c+5+z6D99yHBr5eG+6RTynYd6CqHHglfNVKAx1FG++j0
         zm1R8I9ZU447oHzMFYyHMz890ULjemRH+Xzg7p6eMpFBpVHDhsh+JIIIFZKtXYnu+1bI
         a7MeTTF/AFv84SuJ9pDtE0FFYovRKTi3bwtTvJEYB73wPuO4MIz+86mhp2hPRW60bWFp
         m4mA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=X2QdwSYD;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y10sor5351978iol.85.2019.02.25.21.40.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Feb 2019 21:40:17 -0800 (PST)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=X2QdwSYD;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=d2WRTnzkd0HHCIjHVGDZyo2Tadbbej1CTbAbmG5YY9w=;
        b=X2QdwSYDVj6jxsGxJsdDJJneo6b5fquN5fFtA6SykEWJhLqubJcPoWN5lKnxJKKz67
         Fonk5NMgG1cE+lSUaX4QR7Tff6pZu0LW/yY9J+M3MT8l5V3Nqwu16EgSN+q+1RBjcLK0
         QyYPzDcRfCdllfLMObOJC50abCmOuYJJag55a7i3XjGhR/zyzUeuMnqM+WrRocLSjv5y
         uu2C1M5t3jNMiKJ9omydhdJkJJ8N4TsUDBjP9cK/PLm1vOeyBZh3YzzeEwHAK/nrhwN5
         hxHuHMUiHRz0zd+MWkStMTfICfV5WFnYTt9M9fi9v6r5fxvirvG2nyXtSLGC/ibOaVgc
         Xb0w==
X-Google-Smtp-Source: AHgI3IZjrjSzD1nRszTH2FEyQdqiRXJzhZJUWFL6BsYzsCiCOsSM+KaJ+E2jSbQUfSQcLFlJhighGurgkx9xiEQVaFE=
X-Received: by 2002:a6b:ca87:: with SMTP id a129mr10644521iog.281.1551159617251;
 Mon, 25 Feb 2019 21:40:17 -0800 (PST)
MIME-Version: 1.0
References: <1551011649-30103-1-git-send-email-kernelfans@gmail.com>
 <1551011649-30103-3-git-send-email-kernelfans@gmail.com> <0371b80b-3b4c-2377-307f-2001153edd19@intel.com>
In-Reply-To: <0371b80b-3b4c-2377-307f-2001153edd19@intel.com>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Tue, 26 Feb 2019 13:40:05 +0800
Message-ID: <CAFgQCTtuy=ueX_Eb5Z56SKMACc05qtPMJOw-WAgBbCAH_wZyjA@mail.gmail.com>
Subject: Re: [PATCH 2/6] mm/memblock: make full utilization of numa info
To: Dave Hansen <dave.hansen@intel.com>
Cc: x86@kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, 
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, 
	Dave Hansen <dave.hansen@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, 
	Mike Rapoport <rppt@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, 
	Andy Lutomirski <luto@kernel.org>, Andi Kleen <ak@linux.intel.com>, Petr Tesarik <ptesarik@suse.cz>, 
	Michal Hocko <mhocko@suse.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Jonathan Corbet <corbet@lwn.net>, 
	Nicholas Piggin <npiggin@gmail.com>, Daniel Vacek <neelx@redhat.com>, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 25, 2019 at 11:34 PM Dave Hansen <dave.hansen@intel.com> wrote:
>
> On 2/24/19 4:34 AM, Pingfan Liu wrote:
> > +/*
> > + * build_node_order() relies on cpumask_of_node(), hence arch should
> > + * set up cpumask before calling this func.
> > + */
>
> Whenever I see comments like this, I wonder what happens if the arch
> doesn't do this?  Do we just crash in early boot in wonderful new ways?
>  Or do we get a nice message telling us?
>
If doesn't do this, this function will crash. It is a shame but a
little hard to work around, since this function is called at early
boot stage, things like cpumask_of_node(cpu_to_node(cpu)) can not work
reliably, and we lack of an abstract interface to get such information
from all archs. So I leave this to arch's developer.

> > +void __init memblock_build_node_order(void)
> > +{
> > +     int nid, i;
> > +     nodemask_t used_mask;
> > +
> > +     node_fallback = memblock_alloc(MAX_NUMNODES * sizeof(int *),
> > +             sizeof(int *));
> > +     for_each_online_node(nid) {
> > +             node_fallback[nid] = memblock_alloc(
> > +                     num_online_nodes() * sizeof(int), sizeof(int));
> > +             for (i = 0; i < num_online_nodes(); i++)
> > +                     node_fallback[nid][i] = NUMA_NO_NODE;
> > +     }
> > +
> > +     for_each_online_node(nid) {
> > +             nodes_clear(used_mask);
> > +             node_set(nid, used_mask);
> > +             build_node_order(node_fallback[nid], num_online_nodes(),
> > +                     nid, &used_mask);
> > +     }
> > +}
>
> This doesn't get used until patch 6 as far as I can tell.  Was there a
> reason to define it here?
>
Yes, it gets used until patch 6. Patch 6 has two groups of
pre-requirements [1-2] and [3-5]. Do you think reorder the patches and
moving [3-5] ahead of [1-2] is a better choice?

Thanks and regards,
Pingfan

