Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D5F48C10F14
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 12:49:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8EA0C206A3
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 12:49:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="msYnu0kx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8EA0C206A3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2F9AA6B0003; Tue, 23 Apr 2019 08:49:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 280366B0006; Tue, 23 Apr 2019 08:49:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1228D6B0007; Tue, 23 Apr 2019 08:49:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id E34846B0003
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 08:49:22 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id i84so9258945iof.13
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 05:49:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=35dsPaMjiCJMbp0smPFnBa37kyiFHneebblaSoEgPnQ=;
        b=XmtNL3CGcYrtrCo4HfgfZR+u1VtAkbirtFf1UDMUah5QqP4xp5Y0jHsa2xpkYH3qre
         Lesgk0NIvHjEvQgNQkmDtKHMCyZWGV275gV1sPSsxm1tvkm6i0uilNOGnHoIwL6/6DAc
         ze95g8MGXar3LkbtNaa1/NhjqTTQQQprDD9Podp2JA69O6/qYA/pkQ3fNG8+ugmjaYGj
         iZ4Y0BtBPxLmLLGnp7jABxLXZnh/yKhnXBYHj+DX/RiLfzLmYYuqwC48cbBKq3RnlydA
         dDK4vCZhXykGDLfYDec0YU74ot9gznzslgSjBCFzzX6AfXTGTfMYYU0cpgv33MtWPWd6
         xBFw==
X-Gm-Message-State: APjAAAWEV7zr0puxm+QVXh/axznH+r/949RpyBo8nGW/5d7VUAGH0E2G
	SmllGdrUHcTKc1gWQK/hjPI4K5t4jQH2hk+/HkwaIahZ758J9xI5RFQVM2RTB110hTR9P6U7WUw
	erQvY1yneWGJte1h89tAq7bkA3DWWiPvJqOjLpsE/3mjB3iq/LR9It1ZqF8IYgHMuLg==
X-Received: by 2002:a02:bb04:: with SMTP id y4mr17145869jan.67.1556023762714;
        Tue, 23 Apr 2019 05:49:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxifPQj3sh2BKxha1mLAYHw+3UdODG0PhznzKNGgNc7A1YskqZ4livS2my1RnhMstes6MXS
X-Received: by 2002:a02:bb04:: with SMTP id y4mr17145827jan.67.1556023762126;
        Tue, 23 Apr 2019 05:49:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556023762; cv=none;
        d=google.com; s=arc-20160816;
        b=sTO0EWhf+NkF6P7+ribyDUG5DoAuW/xfQFOwnkC6HS05iGC49bbl/fJhxOHXGsE7lh
         Mhhal2tEbT0UinRujRpxpmrESZtQ/zgNNHZwh5hkvSUSPywpYM7y91JcLMBven+cyXph
         LBk5goKJC+mGOVgsm/6sn2GLlFjM2yvQJFBemf8k35TdJx/vMw+wqo5tRnBEGeG+wsTj
         HMM69Q6Q4PwhCUl6PGA12GrUMqDXP3lrKa3LsoQLAo+oQrmMV70ryTWJebUDeXZb9ue7
         kg+P7y2w4xHxgQzvTAmzVSubL/COu1U7qiPUjqCurREVdMHhrHnYVOQO2hpvZskf8ujT
         lqnA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=35dsPaMjiCJMbp0smPFnBa37kyiFHneebblaSoEgPnQ=;
        b=JRps1onw+FFgAbbgF3MQc75YBAmHYRFrfd35FH3zskl1/g4Ue06rT39IpOiKpBhgVV
         qTrCP2M6dUouoeqQjwZ3JBXZMzHyk25GF6aj6ZRAlAZDqVv0sZx8h4cewGitreW8FOxn
         XETPA7zl0NwwvEcibHm2VhRWVlbJfVpB6C105SQc64DIWnIEjlKSzKPfj8ccPLnZpQVc
         TPRPeomxUwVHs30/Asbl3m48GEwV6VSPeUsHHG1h4pdu0kFR/BoV198zkXwRGepsmW2o
         9Wfu5hdY/yGiKr3AJirWQfK+56wR3TM/KJ5k9kgCtFwRedeH+ccLcIzZcn2bmAHmaXtq
         zg6Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=msYnu0kx;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id y20si158444ioc.55.2019.04.23.05.49.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 23 Apr 2019 05:49:22 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=msYnu0kx;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=35dsPaMjiCJMbp0smPFnBa37kyiFHneebblaSoEgPnQ=; b=msYnu0kx2JON/wV/5dmMl8vxA
	dNCkZAqilQAWKgXdb+pllDgIM1dvdIRn2PTFPCpPa2rT6jXvYFDwgwJ3h3lZoIhmej0toM48+/ppr
	RohELwfLN2xCfUtByxgahp0hU50CmU7ZInrqna7acSRDLG6c3QibbucubGNFtCp9B+Y0ozgd2WT4o
	YmvDH3/dt8VwyJiZCrP/zGJP5MwJsY7HaKgut9UodsIMQT0oida9zEnUjEPcD1ArwgTEhu1ogh2g7
	uhCboq8dRcEn79wKSzqUJPyUl3ZBauPLrK9e+FM9A3107dB1aRvokG5XAdcEqf5koNpX4UdSCUGyU
	i6pxQQxMA==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hIuqu-0004F8-De; Tue, 23 Apr 2019 12:48:48 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id A6FE829B8FE27; Tue, 23 Apr 2019 14:48:45 +0200 (CEST)
Date: Tue, 23 Apr 2019 14:48:45 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Michal Hocko <mhocko@kernel.org>, Michel Lespinasse <walken@google.com>,
	Laurent Dufour <ldufour@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Kirill A. Shutemov" <kirill@shutemov.name>,
	Andi Kleen <ak@linux.intel.com>, dave@stgolabs.net,
	Jan Kara <jack@suse.cz>, aneesh.kumar@linux.ibm.com,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	mpe@ellerman.id.au, Paul Mackerras <paulus@samba.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>,
	Will Deacon <will.deacon@arm.com>,
	Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
	sergey.senozhatsky.work@gmail.com,
	Andrea Arcangeli <aarcange@redhat.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	kemi.wang@intel.com, Daniel Jordan <daniel.m.jordan@oracle.com>,
	David Rientjes <rientjes@google.com>,
	Jerome Glisse <jglisse@redhat.com>,
	Ganesh Mahendran <opensource.ganesh@gmail.com>,
	Minchan Kim <minchan@kernel.org>,
	Punit Agrawal <punitagrawal@gmail.com>,
	vinayak menon <vinayakm.list@gmail.com>,
	Yang Shi <yang.shi@linux.alibaba.com>,
	zhong jiang <zhongjiang@huawei.com>,
	Haiyan Song <haiyanx.song@intel.com>,
	Balbir Singh <bsingharora@gmail.com>, sj38.park@gmail.com,
	Mike Rapoport <rppt@linux.ibm.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	haren@linux.vnet.ibm.com, Nick Piggin <npiggin@gmail.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Tim Chen <tim.c.chen@linux.intel.com>,
	linuxppc-dev@lists.ozlabs.org, x86@kernel.org
Subject: Re: [PATCH v12 00/31] Speculative page faults
Message-ID: <20190423124845.GS4038@hirez.programming.kicks-ass.net>
References: <20190416134522.17540-1-ldufour@linux.ibm.com>
 <CANN689F1h9XoHPzr_FQY2WfN5bb2TTd6M3HLqoJ-DQuHkNbA7g@mail.gmail.com>
 <20190423104707.GK25106@dhcp22.suse.cz>
 <20190423124148.GA19031@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190423124148.GA19031@bombadil.infradead.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 23, 2019 at 05:41:48AM -0700, Matthew Wilcox wrote:
> On Tue, Apr 23, 2019 at 12:47:07PM +0200, Michal Hocko wrote:
> > Well, I believe we should _really_ re-evaluate the range locking sooner
> > rather than later. Why? Because it looks like the most straightforward
> > approach to the mmap_sem contention for most usecases I have heard of
> > (mostly a mm{unm}ap, mremap standing in the way of page faults).
> > On a plus side it also makes us think about the current mmap (ab)users
> > which should lead to an overall code improvements and maintainability.
> 
> Dave Chinner recently did evaluate the range lock for solving a problem
> in XFS and didn't like what he saw:
> 
> https://lore.kernel.org/linux-fsdevel/20190418031013.GX29573@dread.disaster.area/T/#md981b32c12a2557a2dd0f79ad41d6c8df1f6f27c
> 
> I think scaling the lock needs to be tied to the actual data structure
> and not have a second tree on-the-side to fake-scale the locking.

Right, which is how I ended up using the split PT locks. They already
provide fine(r) grained locking.

