Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 32311C10F14
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 09:47:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DFC1520843
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 09:46:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="ugxlEb4s"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DFC1520843
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 83C2A6B000A; Tue, 23 Apr 2019 05:46:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7C5116B000C; Tue, 23 Apr 2019 05:46:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6B4ED6B000D; Tue, 23 Apr 2019 05:46:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4804D6B000A
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 05:46:59 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id a7so12693503ioq.3
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 02:46:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=ZG2dlcWtNNZxXUbPH3bRjuZncLwEfGlDXtch5CgLX/Q=;
        b=SNDicKcVQj7Dp4JcHTbbH0053KkRZkOcX1s+70OjVV+GgYwCMGIwZLMh9ohaPDYnW6
         Vv1wAMYjuoWCgHVsgUDybm4kqWUJw0/7aC21NMbpqwTxcvIfqjbo8zpjaBF4GCuDZAKO
         bqapR9EzECVugseOtO9Kq4sBx5vHtHvVEd3vA535WHBFi+U81SofoWziwEVVy1IkK4uN
         TsZ1dkmaNre88ZM++alkK0RIMh9qxq36QcFs91t5a/qUmg9J0+jr7fBQIdlTuGzCiV+h
         QN01PsU/hkdvo/djwLdl0tcy2K4xU5WH7CLzgudDmLv4fGSCwQRVHs8AhRpEgnfIUJrH
         D0UA==
X-Gm-Message-State: APjAAAUQ6KxL83fUZP0sh+QBuo+FktLUY5DjVl18/WR1KJvh/VVn9Rzi
	NQexA2WL9AJnKRIKr5tkuRr+iYMBMGK/PbEdzkWn806Ymbe3aIXTy9cf4yLtXAxp1uYYsia7KNF
	Hk6l6zPO0MBEJ6TT8sFnpNWP69P9YcrRCUrPJ4wweUaeTtUinXaghm6xF/uXDe56qLA==
X-Received: by 2002:a6b:7401:: with SMTP id s1mr16899140iog.55.1556012819067;
        Tue, 23 Apr 2019 02:46:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw6nFO5GRLpgtooeUAhPDb0SMK4eHfiExsKVvS0KWKHRdas33VuEJaUlguJUb7Er4LmuUmZ
X-Received: by 2002:a6b:7401:: with SMTP id s1mr16899113iog.55.1556012818560;
        Tue, 23 Apr 2019 02:46:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556012818; cv=none;
        d=google.com; s=arc-20160816;
        b=BHXqFPwVoYsJhIsxoqOjPyKMW0lsxbATWNF0inn+RZ/kgkqp6h2TbPQQ5XTrpO3Ryr
         Sk0fG+dFHsFhkIPW8nD352uovmufftIH3SnOCOFus6DJ3Y5zIRpp2gViF48SDq9M0NKi
         FCGzXb/jPp3dwpqLjHvh8UOefLA66pi6tmvzjyQdcCcFP3p7qCjzJrfWBat64b5A9bMC
         MmNAS/vPQge2kMC5t2POCD/J4hvNT/3X6Gnk0z4pJkD93+BzlFeNkPeV3r831hoGNFlH
         m8CRSQowWiu9RVrGpzRKaqBWW0qVjYkSNHFeSaM4Ym23Uyczp9YZweWzviOrcouBiskk
         Hyvw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=ZG2dlcWtNNZxXUbPH3bRjuZncLwEfGlDXtch5CgLX/Q=;
        b=wIjwemELiXCOK4RCV3p23+E6gSiitGO/5//RJ17Le8ik2cRi03OvklMcXWl2RL+B2m
         YfDSRDmlhmcZvyCGuibs58E7iMZXq53kIEstqf2kFkc9Mchf7gw9ffv6cR6ENwkW/4iU
         +gCAGQbPigpmXUwCmS0bs62I0Ut9sniw3SjxpOuRujo/Ke1bDpjv8i0fVz9Jy1UxVu76
         l9RafKJUCp/5DnsAb1taBoZ0OqUrX5A0GWFOhSAEseR2vzGmqIqQk2O1y1A7fepvDIe/
         VECfy0EE8YnTVB1AFykLrpHK0kzaojFvzCETLGF0Q/PeJPKGDf/tPrFRJ8iIjDauKQMv
         9ETA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=ugxlEb4s;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id x5si9707951itk.84.2019.04.23.02.46.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 23 Apr 2019 02:46:58 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=ugxlEb4s;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Transfer-Encoding:
	Content-Type:MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:
	Sender:Reply-To:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=ZG2dlcWtNNZxXUbPH3bRjuZncLwEfGlDXtch5CgLX/Q=; b=ugxlEb4sjNIY7tZ9fUhvPMHXXL
	dXph+KhM7zeyt15QyBaGwE6z3hplR611VfhoWEnpYrCFyeVwt1CiJmkU+ZUgYpUBZBzZ8xMkVC0Bd
	Cuyt2hcODWc7MePUpOEx04npM6xiW5Og/Xg5BSH1pv/xvWluPRm78OoWtdweWgAW/yQhlacPCsy2+
	/GS59LBtvC680KFoiyN8Kwx9tGyCZUf1UbSteH7UUMaH/N+HDON84XC/sY+qJy4polvo72cGFRit+
	tzpzGj1CDVDCE0N31jhJRk7yVvsrJ0Qx5cEawHUkBckIXuiK6VwoVEzSMxwlIZ1cXO2WXNPcoQA02
	PDecM9Zw==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hIs0j-00020N-RA; Tue, 23 Apr 2019 09:46:46 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 9A37A29BF8E8B; Tue, 23 Apr 2019 11:46:44 +0200 (CEST)
Date: Tue, 23 Apr 2019 11:46:44 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: =?utf-8?B?546L6LSH?= <yun.wang@linux.alibaba.com>
Cc: hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com,
	Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [RFC PATCH 2/5] numa: append per-node execution info in
 memory.numa_stat
Message-ID: <20190423094644.GL11158@hirez.programming.kicks-ass.net>
References: <209d247e-c1b2-3235-2722-dd7c1f896483@linux.alibaba.com>
 <7be82809-79d3-f6a1-dfe8-dd14d2b35219@linux.alibaba.com>
 <20190423085248.GE11158@hirez.programming.kicks-ass.net>
 <8c3ad96d-7f3d-d966-6acc-8327023ae3f9@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <8c3ad96d-7f3d-d966-6acc-8327023ae3f9@linux.alibaba.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 23, 2019 at 05:36:25PM +0800, 王贇 wrote:
> 
> 
> On 2019/4/23 下午4:52, Peter Zijlstra wrote:
> > On Mon, Apr 22, 2019 at 10:12:20AM +0800, 王贇 wrote:
> >> This patch introduced numa execution information, to imply the numa
> >> efficiency.
> >>
> >> By doing 'cat /sys/fs/cgroup/memory/CGROUP_PATH/memory.numa_stat', we
> >> see new output line heading with 'exectime', like:
> >>
> >>   exectime 24399843 27865444
> >>
> >> which means the tasks of this cgroup executed 24399843 ticks on node 0,
> >> and 27865444 ticks on node 1.
> > 
> > I think we stopped reporting time in HZ to userspace a long long time
> > ago. Please don't do that.
> 
> Ah I see, let's make it us maybe?

ms might be best I think.

