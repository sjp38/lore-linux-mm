Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B8BAEC04E87
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 05:01:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7B47D21743
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 05:01:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="j6GM2Wd1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7B47D21743
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2048D6B0006; Tue, 21 May 2019 01:01:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1B4DE6B0007; Tue, 21 May 2019 01:01:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 008846B0008; Tue, 21 May 2019 01:01:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id BAA196B0006
	for <linux-mm@kvack.org>; Tue, 21 May 2019 01:01:52 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id 14so11325943pgo.14
        for <linux-mm@kvack.org>; Mon, 20 May 2019 22:01:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=QoDuJHrLBQ/xwGBwHKCt2IBJytG8/Ex5Sv/y0ADsw9A=;
        b=EIeEBgBu9e7xeJFIu4zg2lO/NgvkuO8tnVVzy1mwwvT5vtwces5xSOm+qeGteRVPcy
         CV3LM/KDblzqeecK9A1e84H8PvDFIP9CZjW+2SIG9IFM1I97gfWDLnQ7XdAHwBcIuexI
         TbNt/42CpBINyHx/W5q9htmTMCJyg8LBR8sfTH9iIfUy92aYys0ADXDuTEcdtRdN44TT
         kGdyeYxBP3IhFHzwXUbdL4QIPAkrbsVBou/rPj7MPpSRl5AdSMyZdL+ZUy2V2JvTSN+W
         h+myuoyle3sJGbUQVaaZ17bEhMVHcnEuFcFFQs6zgfNTktaawPcX3r5UhGwiOmMBrJJ6
         pbgA==
X-Gm-Message-State: APjAAAUVmz4tEz8z3mSJJEePp3LGZGG61rWLLDc5fpubUGnbbYRBja9Y
	+Aqx7v14iV6Gft4BmjFmR3jyVj/ZsAqUFM3j2GoBW3xt0562H6QiNpiD4ITkd5jnmzWZ/AGzNsf
	20EH4ym1vereDQ91hTatF6bD0YEMMMIWe5K+n+cej7BVse/t17dzWPpwnLQCSuOw=
X-Received: by 2002:a17:902:e00a:: with SMTP id ca10mr81981491plb.18.1558414912304;
        Mon, 20 May 2019 22:01:52 -0700 (PDT)
X-Received: by 2002:a17:902:e00a:: with SMTP id ca10mr81981401plb.18.1558414911364;
        Mon, 20 May 2019 22:01:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558414911; cv=none;
        d=google.com; s=arc-20160816;
        b=083/+C7HLZvJofOv1HDP6TklqNYqViXtzwkrftFf9w45peZTwJ2W383XFerHXD+QlU
         XMpRoiCp1pu5sytZimYyRsuw1fpMH4/qxPQT032a3vlU8ZyNqgJrPQtRTH7dHG2leByd
         a+hwvJCMP059FFpJcZc1UtNgNVCKLr3ECC4Mj3xG2nli5RZ1z1hhCtfQEvZAH96U3R/I
         gwJu5pCUm1nkQGgyVN8Yu08XB2PfkcuNljKNIMUmyo/SXZDr8L8R/QwdRykrJOSiRxCn
         HG4zKrExsCjHZsFpJ/8+0vj9hXdDw5rFoSOwBv0p/uPG4iDohFI0wPFKAjeY23R6Iezk
         Jkaw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=QoDuJHrLBQ/xwGBwHKCt2IBJytG8/Ex5Sv/y0ADsw9A=;
        b=cei8L0EWphQFO9F0781dtiApfPeF48wwp9hix88wnScVtoxT1KAkVG4K+6BEpnB2IX
         yzn3ZZKSdP3j4QGeXjB8jMai5+BYPawqjVGL9lYVft/XxfjfddLk8HCqtsF0ZJPuysvj
         WU9Lm0gxL46YMVkkwe3KkEFwPSZuHTeV4YuGs4hGSLm9WwKKI5hPCw1Pv4TVdTB1uudW
         MztWX4DoVeBar7BSg3/q1+scTbrA6oAYGR1fA7T/8WvQ3CscUlxda7825rKZEw27jX54
         +x0MjFYqfXM0SwLaWWCsZL5yz9zD6YNJCo95yRtUyZjQyMAt2vVKHcClY1Q3aWEOkyeS
         ViUg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=j6GM2Wd1;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 3sor21434316pfa.24.2019.05.20.22.01.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 20 May 2019 22:01:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=j6GM2Wd1;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=QoDuJHrLBQ/xwGBwHKCt2IBJytG8/Ex5Sv/y0ADsw9A=;
        b=j6GM2Wd15hhYbHOpmjGikLz1Yeo8XKNvknmNfEyF4ygPaaXBNSh6MEOembaOV6xba5
         5lgIbRbxvKNW2MBKsDZ5qYikCnCq5FQlHcx3r5v2Xt3nzvJlEkPTkTY0vitEKORsfrLJ
         t0G+0bT2uvVuXYIeWA/clAlNGdGrDJHUxBPTWTRWcM+epfdoB9ifCLdS8BYINhPU1y5o
         74BaFoZ8ibyH+goPRw9iMY3cLhpRHuTt7b1qYg1e4Abi3JU/xfbsu1CimUBvZAX41rNv
         QurGjtazYmaLBIhndMYwtMMP9u3pAYR0PlvWjv6zwenkmsbJgigfQD6WYqpWgtn7tqTd
         11jA==
X-Google-Smtp-Source: APXvYqyJH0J5FSk3fdPjh9d4XeRJ+4EEk9eUbgIyEI9pQ/tWso7pSHIofovJWiwS4/R/xQ1KB0n76Q==
X-Received: by 2002:aa7:8f2f:: with SMTP id y15mr74227321pfr.124.1558414910967;
        Mon, 20 May 2019 22:01:50 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id p13sm12382900pfq.69.2019.05.20.22.01.46
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 20 May 2019 22:01:49 -0700 (PDT)
Date: Tue, 21 May 2019 14:01:44 +0900
From: Minchan Kim <minchan@kernel.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Michal Hocko <mhocko@suse.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>
Subject: Re: [RFC 0/7] introduce memory hinting API for external process
Message-ID: <20190521050144.GK10039@google.com>
References: <20190520035254.57579-1-minchan@kernel.org>
 <20190521014452.GA6738@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190521014452.GA6738@bombadil.infradead.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 20, 2019 at 06:44:52PM -0700, Matthew Wilcox wrote:
> On Mon, May 20, 2019 at 12:52:47PM +0900, Minchan Kim wrote:
> > IMHO we should spell it out that this patchset complements MADV_WONTNEED
> > and MADV_FREE by adding non-destructive ways to gain some free memory
> > space. MADV_COLD is similar to MADV_WONTNEED in a way that it hints the
> > kernel that memory region is not currently needed and should be reclaimed
> > immediately; MADV_COOL is similar to MADV_FREE in a way that it hints the
> > kernel that memory region is not currently needed and should be reclaimed
> > when memory pressure rises.
> 
> Do we tear down page tables for these ranges?  That seems like a good

True for MADV_COLD(reclaiming) but false for MADV_COOL(deactivating) at
this implementation.

> way of reclaiming potentially a substantial amount of memory.

Given that consider refauting are spread out over time and reclaim occurs
in burst, that does make sense to speed up the reclaiming. However, a
concern to me is anonymous pages since they need swap cache insertion,
which would be wasteful if they are not reclaimed, finally.

