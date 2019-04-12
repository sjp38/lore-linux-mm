Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 26BDDC10F0E
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 20:50:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CDADF20850
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 20:50:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="FNfanZT+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CDADF20850
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7D6136B0273; Fri, 12 Apr 2019 16:50:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 75E4A6B0274; Fri, 12 Apr 2019 16:50:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 625136B0275; Fri, 12 Apr 2019 16:50:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3B3016B0273
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 16:50:15 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id w6so7882023ywd.2
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 13:50:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=j7qwsRw5IVivpTyLBIatOTcD/RB+ixEMBFLpFto3jKc=;
        b=fJ+BQBEBESOxf+d0ALAAr8dnDcEzlxNLtvvz6x3ObptoeFAOrWmIGXS5MyJkYphVjZ
         PhhJ2Dkyqcg3Xja2+FI5dQ4rW/nk3z1tVY4UOpSPWGhEn9v/TkwQPtND7njNBbz36uNl
         Bjg/hL5ejOuvgwrdcMrezH4XxqX1f9mCLLXbXSrBYrBzHI2aU/AWJVevciJktKMaoHcL
         5vJM4wTZjsKBaDmNakN1ELtU6EBOxe90fb/tkkLr3LDSVUT2daHdCTgXy+6NgkReQ620
         AWHH3w2c0Edfr0cbBG1jWJGi3kdbJgKeQBQO0e1prsSGSTtFNAz64TPP5qWsTvl+ZH0l
         LhWg==
X-Gm-Message-State: APjAAAWIEylWIjwbQmQFxOHeyr17mUUKYd1ntIGCWKc7OZfDMcd+3096
	PBn+lNCOBs5IfT7frAOkW8ORmnYa7VMmt3AxIwztFG0x29LDZD9uZhrqQJLWdKadDXeMNeyItw7
	GlZe0RLVcXR8wsiMx/CFShkgXIMfFcAuV9h3VeVk7z62OoureI0LLJRZ6ssNl1EBueQ==
X-Received: by 2002:a81:234c:: with SMTP id j73mr47040453ywj.327.1555102214981;
        Fri, 12 Apr 2019 13:50:14 -0700 (PDT)
X-Received: by 2002:a81:234c:: with SMTP id j73mr47040406ywj.327.1555102214354;
        Fri, 12 Apr 2019 13:50:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555102214; cv=none;
        d=google.com; s=arc-20160816;
        b=Zj58x0Sl0XTrH6Ym/RkE11EuB7VjPQc4GDbspePhufrjjvjLZ0ABISggsLrJMLtN2p
         ShMQ1LkwjVKY1ECj1bkAlUX+eLk+Xk5WCwGx/E2DxMbAgZpNhGs4sXQNnKMysxJ3Be4C
         pD9htgjqH3zOwk+tVvJPwrB+dLfFwSktRNzKIIPvdmoa5CnIu7xZl7knPioT5cEnUTCi
         0fuLykBZML4W84gdT4amnGMZ9AhgYNBU6nJxlX1ON19gJCbmW4U9z+8XZyYycSOnkFN9
         QodV7L/w7IxJ/SFLFBZuHqq2e3LPkyZDfgvkqIjs1jzeLOLtcvEq91ytivBHRPkszuDz
         unaQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=j7qwsRw5IVivpTyLBIatOTcD/RB+ixEMBFLpFto3jKc=;
        b=J3ytiu3XW6gaC2WCeB1Y86gvuhTUWoMI+uOM3LE6GKTJwDFCTgdBqa8N09ofzBqj1e
         8j4jTcxa2/R7zc2kOW2vhmQh0RhxafkCbsMdY59Yc2+dNDSBscwjIEOU7X6F/yGSE2zG
         2Oan4ogbQHWGBqs9SZPxjVtFYUNoxHbOJlCs8K+0FxduSJv/38xNspxTngzs99/1+j7J
         59h/auLRidpl2AJaC8EVdBYmmQ6MMG0mdvGuDpgYo3o2r2haJy+D5JN10bCcdYyGdIk3
         U7Ugvwtb1FFNoHE9b9G5Jzk6SdbMghkZcnSbvnupL19m71a8WB7tKS3I65jDHw7lYq97
         BByA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=FNfanZT+;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 135sor14650475yww.116.2019.04.12.13.50.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 12 Apr 2019 13:50:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=FNfanZT+;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=j7qwsRw5IVivpTyLBIatOTcD/RB+ixEMBFLpFto3jKc=;
        b=FNfanZT+pHyXePPyxtbvwcA0HSyUlLfO69/0C0yMTEEwkqZGMDKqTnsD34jUcSJwSW
         H+rD2xu0SDTdcw2PMP5wOdnzg2MxqLtDyXmgf+SrP+4HztAQxIIZxBF+bICluUkir/pY
         c8cRuA0THxpAqVC/043WDsTwSO7azcuGV8s3Vue48TZYoJ5syonT16R4SA6/Mj9qtuXt
         5KndgfyXwhPPDpn/a2Z3w1WxKVQRod5rlcVAAlA/Um8fPjD//D1ASejBz38ApivCap2q
         aXtwz0gMjra9X61DONZSTYp0024btZjJXF98c64BfCEZ2hl5rI6OgykrOJAXItWBazR8
         8n0A==
X-Google-Smtp-Source: APXvYqyayhbtQZ1S8kD8Qek+eW5XNvWOoa8xBKC1ooATGN/pyfvB4oZsltCbWCl2h3eCaoJoYHi6iBozkNsniEk8QkQ=
X-Received: by 2002:a81:9ad0:: with SMTP id r199mr47081086ywg.310.1555102213675;
 Fri, 12 Apr 2019 13:50:13 -0700 (PDT)
MIME-Version: 1.0
References: <20190412151507.2769-1-hannes@cmpxchg.org> <20190412151507.2769-4-hannes@cmpxchg.org>
 <CALvZod4xu10+E41YyaamigysZAnDcdA09f5m-hGd72LeJ9VmEg@mail.gmail.com> <20190412201534.GB24377@tower.DHCP.thefacebook.com>
In-Reply-To: <20190412201534.GB24377@tower.DHCP.thefacebook.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Fri, 12 Apr 2019 13:50:02 -0700
Message-ID: <CALvZod6jPxRb=ZEtErvZ4nJnObhQN05ECO9d_=HF0UWsCZExNw@mail.gmail.com>
Subject: Re: [PATCH 3/4] mm: memcontrol: fix recursive statistics correctness
 & scalabilty
To: Roman Gushchin <guro@fb.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Linux MM <linux-mm@kvack.org>, Cgroups <cgroups@vger.kernel.org>, 
	LKML <linux-kernel@vger.kernel.org>, Kernel Team <Kernel-team@fb.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 12, 2019 at 1:16 PM Roman Gushchin <guro@fb.com> wrote:
>
> On Fri, Apr 12, 2019 at 12:55:10PM -0700, Shakeel Butt wrote:
> > On Fri, Apr 12, 2019 at 8:15 AM Johannes Weiner <hannes@cmpxchg.org> wrote:
> > >
> > > Right now, when somebody needs to know the recursive memory statistics
> > > and events of a cgroup subtree, they need to walk the entire subtree
> > > and sum up the counters manually.
> > >
> > > There are two issues with this:
> > >
> > > 1. When a cgroup gets deleted, its stats are lost. The state counters
> > > should all be 0 at that point, of course, but the events are not. When
> > > this happens, the event counters, which are supposed to be monotonic,
> > > can go backwards in the parent cgroups.
> > >
> >
> > We also faced this exact same issue as well and had the similar solution.
> >
> > > 2. During regular operation, we always have a certain number of lazily
> > > freed cgroups sitting around that have been deleted, have no tasks,
> > > but have a few cache pages remaining. These groups' statistics do not
> > > change until we eventually hit memory pressure, but somebody watching,
> > > say, memory.stat on an ancestor has to iterate those every time.
> > >
> > > This patch addresses both issues by introducing recursive counters at
> > > each level that are propagated from the write side when stats change.
> > >
> > > Upward propagation happens when the per-cpu caches spill over into the
> > > local atomic counter. This is the same thing we do during charge and
> > > uncharge, except that the latter uses atomic RMWs, which are more
> > > expensive; stat changes happen at around the same rate. In a sparse
> > > file test (page faults and reclaim at maximum CPU speed) with 5 cgroup
> > > nesting levels, perf shows __mod_memcg_page state at ~1%.
> > >
> >
> > (Unrelated to this patchset) I think there should also a way to get
> > the exact memcg stats. As the machines are getting bigger (more cpus
> > and larger basic page size) the accuracy of stats are getting worse.
> > Internally we have an additional interface memory.stat_exact for that.
> > However I am not sure in the upstream kernel will an additional
> > interface is better or something like /proc/sys/vm/stat_refresh which
> > sync all per-cpu stats.
>
> I was thinking about eventually consistent counters: sync them periodically
> from a worker thread. It should keep the cost of reading small, but
> should increase the accuracy. Will it work for you?

Worker thread based solution seems fine to me but Johannes said it
would be best to not traverse the whole tree every few seconds.

