Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 795CCC48BD6
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 22:25:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3E0D02177B
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 22:25:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="mssNCvDX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3E0D02177B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CA42E8E0005; Wed, 26 Jun 2019 18:25:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C54798E0002; Wed, 26 Jun 2019 18:25:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B6A728E0005; Wed, 26 Jun 2019 18:25:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 810428E0002
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 18:25:57 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id b24so163177plz.20
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 15:25:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=FISy48Rgj/GcTj00q/z53RqLMWKm+vBJGDuVKEpZdxs=;
        b=GdJT/NjAq6gwi3IG+OXVYAaP6ld8BqSGiCJbpCDtbruEuP/shWcb7VzSiWbo045vzf
         5DEgQhAkPsyVMAxzYAKZXgRDhBwLBzoUaEMqm4n8KmyQfWlRg19ejF80MhRNBQ+YhdG8
         5Cak+eNFv0yI0dVHrsTrvPhVr0WiwEEwb29Bu1jrzD9zk58ZN1vLKPXtQHBFiac8FhJT
         rO8CWfx4u1z+zdgnrqAdXnqL8REZFcgtdrKH4k8iAG213uX8pTUw70cmj3NbQDh4DKL3
         afeQAct/RDBSLzLyBK/LSRA64NdOeeDSguBxNYSCndGu7yKBc6xWmlENvQe1N7f64aPn
         H/LQ==
X-Gm-Message-State: APjAAAWXYsdrUjEcU4KO3/70JAtJv4Y6hFrN1IyFfv2YICTIr41H2HnA
	9BRfA7Eb+tvwSUCNPB0LOpRhe1oqn7ns/XoE+7mem6sjsfBiU1ulI1k3PF7nQfsJa1BaRje7qTz
	XtosapwYPmLHBpn2IWTV87/YcKkHyTh8WcIvnuPnNWhawRcngnDtPplA6lIkUXsBXVg==
X-Received: by 2002:a63:d415:: with SMTP id a21mr261822pgh.229.1561587955531;
        Wed, 26 Jun 2019 15:25:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyYH5tEfuTs8FfzqF7P4EAfuInVUgdr1ms7YFDKIHfIOYpgcCIps/6oGrDiOIokBmVwUmaP
X-Received: by 2002:a63:d415:: with SMTP id a21mr261765pgh.229.1561587954529;
        Wed, 26 Jun 2019 15:25:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561587954; cv=none;
        d=google.com; s=arc-20160816;
        b=tal4BsZj4LfVVnBouQJ3QNmq3GluJ8AqkJdILRhDSzpFX4IPS7Km71rdD7YYU+oON2
         4dfyLFoqgP5B/au1s3Z5lYQn2IHMYLAaulwNgd9dkmwbJOSbL/RJ2O2dgLk4o1uuOByR
         oYGvSR6Veax7jroLfasadIlrSzUgAbBf4VZIzrZJ+IaZwSM7BWDGbz0rBqci+ZR4feiM
         L6A5Pno62oePE6P2yoK0wRp1JrX9qftsqRoC59ue6poo8sB8iK2VByG22ndXoSTjEiNt
         RQaJieN0DlJyg+LTLPPp2csC9Bmg1tXQPbcGlgjNzGXyLETeUTghncupSp3mdoezBRFt
         9JcA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=FISy48Rgj/GcTj00q/z53RqLMWKm+vBJGDuVKEpZdxs=;
        b=W3PWRqNek+pRk4KBavHco2CiLcO1BQYm5z8PWQtBDcKGz1Ysra3wOf1gtRujqgEj7S
         cSSyp+sjmwEi9yvgrwGF5hN/EvPCmx1ir048Sf/MPn79tf1wmW/DSXNG0DOF+YWSjwZa
         lrqCLsCs9dtMhUj0bQAnrJSTzNr4shxqBf+cZ/YTP+NNkYo15phSk4Xz5YdBuXPAZvIT
         8ZwLi3wI9Bkv0C6VmVk6m0v1Vu8zOfiDpPU7xZZMv+ymZtdRFKOUrIjOfJ94altYsieI
         L7qKIVziDc4H7ykZo/Qf/E4/ezdobr9H4qG1y5uxIWDq8ICQc/h6i3pNzidgFAig+XgJ
         crFQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=mssNCvDX;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id e21si236029pgh.571.2019.06.26.15.25.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jun 2019 15:25:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=mssNCvDX;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id CB52421738;
	Wed, 26 Jun 2019 22:25:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1561587954;
	bh=dWrZzF/XhnDsjGoEGdLBbSVqFhzeMu0M8np8rL3DeVs=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=mssNCvDXM3lIy9mHu47Fi5QIRccIP4NEIrmBc+mQHupnTW7+YYbhguOoXDqtvERvH
	 REfZC+aT9ppRRnmbB7/H8Yp47SEvjMSnzviL8SITVJOqWUzWaWRjUa5YprDOQSdFxO
	 pQ6Rdu5QWpA8GqFoZXwWmNRKk1ID+8M77YZ7zkKo=
Date: Wed, 26 Jun 2019 15:25:53 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Waiman Long <longman@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>,
 Vladimir Davydov <vdavydov.dev@gmail.com>, Tejun Heo <tj@kernel.org>,
 linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org,
 Shakeel Butt <shakeelb@google.com>
Subject: Re: [PATCH] memcg: Add kmem.slabinfo to v2 for debugging purpose
Message-Id: <20190626152553.6f9178a0361e699a5d53e360@linux-foundation.org>
In-Reply-To: <20190626165614.18586-1-longman@redhat.com>
References: <20190626165614.18586-1-longman@redhat.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 26 Jun 2019 12:56:14 -0400 Waiman Long <longman@redhat.com> wrote:

> With memory cgroup v1, there is a kmem.slabinfo file that can be
> used to view what slabs are allocated to the memory cgroup. There
> is currently no such equivalent in memory cgroup v2. This file can
> be useful for debugging purpose.
> 
> This patch adds an equivalent kmem.slabinfo to v2 with the caveat that
> this file will only show up as ".__DEBUG__.memory.kmem.slabinfo" when the
> "cgroup_debug" parameter is specified in the kernel boot command line.
> This is to avoid cluttering the cgroup v2 interface with files that
> are seldom used by end users.
>
> ...
>
> mm/memcontrol.c | 16 ++++++++++++++++
> 1 file changed, 16 insertions(+)

A change to the kernel's user interface triggers a change to the
kernel's user interface documentation.  This should be automatic by
now :(


