Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9087AC433FF
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 23:03:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3F7712184E
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 23:03:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="UDBUExSY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3F7712184E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B7C9E6B0007; Thu,  8 Aug 2019 19:03:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B2D946B0008; Thu,  8 Aug 2019 19:03:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A1BE36B000A; Thu,  8 Aug 2019 19:03:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6E4256B0007
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 19:03:00 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id x10so60101561pfa.23
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 16:03:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=T8qWIUmD7wGkAlxloMVoZvRGwfU2ts+JoDUUcK4M+5o=;
        b=bZuQyABP2ktoIQu/HBs1S37SyVHq6LdM422VBOXXSJGh/qG2MSQMHpl+LEhmKZTbmA
         nZ4kv+WsI4zt6dawSPUIOMmwLN5DDZ3MguszrVcjpchGInVPHB7/aH1/sbAlYzN8Gc24
         aqx1FtfFXaSx0iyBV4CD6t6zaXtAAwf/ttm28dgqLc/BLZuYxdNc/LPbSIgFHvuztXfA
         ks6r8isPF++5B816sE+JZk6PlGpYbIpbF2DzKC7lf//zIBS/qKryCBlivyJ7zD6sFOyI
         c+TRld9sGueL51cD90BetThGTbaF9d0P80tgFzMSW80cQBWItoFvPlV9rPmlXmpcM6Kv
         QJpQ==
X-Gm-Message-State: APjAAAX0hEO8Yrk2gcHMmKvpeTl4d4byi+LMGVzY4OK9kW5XiGOO3BeZ
	4SnsZ01078g7uXhKOeMFvw/QasVnE5/DvR+ys8xlJu8EFX9+vcEXNOEATjMI9FvM7SiHBowO5FT
	KyTQ2zQZC4e0Mf3QmGs+IdfzDNNZBn9zcRsG2k5nA7mA46g6Kr536J7eWRqp+76WXLg==
X-Received: by 2002:a17:902:9a85:: with SMTP id w5mr15987772plp.221.1565305380115;
        Thu, 08 Aug 2019 16:03:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx2yvyqLbUM/CY3VCSz8a/GzfPnOPcuLfiv8DGBPhuvOX3f2cdI1Qrh/RVYCXxciCdSt1Kk
X-Received: by 2002:a17:902:9a85:: with SMTP id w5mr15987712plp.221.1565305379285;
        Thu, 08 Aug 2019 16:02:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565305379; cv=none;
        d=google.com; s=arc-20160816;
        b=IfZGilSTmu77q4pNmV1GHL/7RZK9dEntyMYqW+KawaTKLUI3DTWne3JjBLrXjSxWZP
         K6dQv+WP57Cpc27U0sWd94Lz5SpWo8qdrOW3Yr2LOnw4Maii4Q5AiwyZBYXV8vEWv8zJ
         CB6ehmCRklb7HYrkCuX5GjRMtHhHBWhzNx33j1T87jc3dFfAycSxofsXRzVIF9KPQkeV
         a3sXgWazkqA9RaaHA9sjdEc0U/Y6wQCk/P80xXP3K7S3u4YxmxWd/JIWb5w3UNXa6VSn
         rCmSCFoXtuuSpccwVlOqzCYly8LiHJyIumlFlj+kVumhWyMu5sQCciuYpCQ1Qdzt5k3B
         AKSg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=T8qWIUmD7wGkAlxloMVoZvRGwfU2ts+JoDUUcK4M+5o=;
        b=Khnw25UPJEVKtYLr1G1g8JiYJpiSn9UUNKiYhgCmnKwZ2w57mZzj6GHtz+ei8nitn8
         udZGTJ4htZWIqYptA2Bw2kTrusplDIwD2DeGJof/S/S3QNoS6vdbOz83vwejfRtMV9MK
         VRHsgGCatnmmcedgEV0YZBuOUp5IUGCoOHUR/xCl/kYdJBl0EqRleEJzdBPDyR+Y980S
         NCGGAcHkR/PB3v/RxQJGa4U4B01ukFZNd5uQ/kacnuJz2SzcJQANvi625w9hcYvYoEoT
         cU4V+W4BusevDGzU+fli6ZRIvvRbiGAlYpZrY/E5I/9HPZhfOMazL/CdbuMF/WMlE0fJ
         F8Tw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=UDBUExSY;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id u17si56067533pfc.210.2019.08.08.16.02.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 16:02:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=UDBUExSY;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 925222173E;
	Thu,  8 Aug 2019 23:02:58 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1565305378;
	bh=wZTH8XgTxxxVDsQPmD/QFT6okbtnIXw2oHs1b6PpWBQ=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=UDBUExSYm5sCUD0TghXG06OJsGqPu1AZfFGCiep9coMJJWoxYuTgOrUbpq3rhPlbK
	 P4mxpyszZn3CduH+ZquqIGCSZtQsYq2m8lpFlOinhHVXzA5Y6T/Q2/RjMtDHbkfL1T
	 HQVHpeuUaWr/qz9fOvQvXscbDoInTLdElTBfNXWU=
Date: Thu, 8 Aug 2019 16:02:57 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Roman Gushchin <guro@fb.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Michal Hocko
 <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Kernel Team
 <Kernel-team@fb.com>
Subject: Re: [PATCH] mm: memcontrol: flush slab vmstats on kmem offlining
Message-Id: <20190808160257.bce08b5ae1574414f96ee26b@linux-foundation.org>
In-Reply-To: <20190808214706.GA24864@tower.dhcp.thefacebook.com>
References: <20190808203604.3413318-1-guro@fb.com>
	<20190808142146.a328cd673c66d5fdbca26f79@linux-foundation.org>
	<20190808214706.GA24864@tower.dhcp.thefacebook.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 8 Aug 2019 21:47:11 +0000 Roman Gushchin <guro@fb.com> wrote:

> On Thu, Aug 08, 2019 at 02:21:46PM -0700, Andrew Morton wrote:
> > On Thu, 8 Aug 2019 13:36:04 -0700 Roman Gushchin <guro@fb.com> wrote:
> > 
> > > I've noticed that the "slab" value in memory.stat is sometimes 0,
> > > even if some children memory cgroups have a non-zero "slab" value.
> > > The following investigation showed that this is the result
> > > of the kmem_cache reparenting in combination with the per-cpu
> > > batching of slab vmstats.
> > > 
> > > At the offlining some vmstat value may leave in the percpu cache,
> > > not being propagated upwards by the cgroup hierarchy. It means
> > > that stats on ancestor levels are lower than actual. Later when
> > > slab pages are released, the precise number of pages is substracted
> > > on the parent level, making the value negative. We don't show negative
> > > values, 0 is printed instead.
> > > 
> > > To fix this issue, let's flush percpu slab memcg and lruvec stats
> > > on memcg offlining. This guarantees that numbers on all ancestor
> > > levels are accurate and match the actual number of outstanding
> > > slab pages.
> > > 
> > 
> > Looks expensive.  How frequently can these functions be called?
> 
> Once per memcg lifetime.

iirc there are some workloads in which this can be rapid?

> > > +	for_each_node(node)
> > > +		memcg_flush_slab_node_stats(memcg, node);
> > 
> > This loops across all possible CPUs once for each possible node.  Ouch.
> > 
> > Implementing hotplug handlers in here (which is surprisingly simple)
> > brings this down to num_online_nodes * num_online_cpus which is, I
> > think, potentially vastly better.
> >
> 
> Hm, maybe I'm biased because we don't play much with offlining, and
> don't have many NUMA nodes. What's the real world scenario? Disabling
> hyperthreading?

I assume it's machines which could take a large number of CPUs but in
fact have few.  I've asked this in response to many patches down the
ages and have never really got a clear answer.

A concern is that if such machines do exist, it will take a long time
for the regression reports to get to us.  Especially if such machines
are rare.

> Idk, given that it happens once per memcg lifetime, and memcg destruction
> isn't cheap anyway, I'm not sure it worth it. But if you are, I'm happy
> to add hotplug handlers.

I think it's worth taking a look.  As I mentioned, it can turn out to
be stupidly simple.

> I also thought about merging per-memcg stats and per-memcg-per-node stats
> (reading part can aggregate over 2? 4? numa nodes each time). That will
> make everything overall cheaper. But it's a separate topic.

