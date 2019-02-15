Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7A718C43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 08:58:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 39AC92190C
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 08:57:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="gT8IzfYM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 39AC92190C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C48328E0002; Fri, 15 Feb 2019 03:57:43 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BCF238E0001; Fri, 15 Feb 2019 03:57:43 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A705C8E0002; Fri, 15 Feb 2019 03:57:43 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 648AE8E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 03:57:43 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id g13so6389695plo.10
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 00:57:43 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=lC0sJXKkNVKrNcwoJXfFFpIZaHgwwYjVNEpuiQ0lz3E=;
        b=h7bLU5UPAZkzwi7slopVgb5f2QaruKXoQFETgpyjxIiZQfD7xet1XMu8524p2xa5Se
         yFZDxsxPalbqmOa4Wy4pODOWL6ow3TCh5NXhbxQ4Pb2DVLphsh6QI1PKGYxnYyRznNrU
         iZ8EZWgvmwgEWIPs60c6nIO3CApMJu9n4ulAr7fJzoi1cwhUhXaLt2BReMLSFBDQw6L5
         R0Jdj2Ve6b7yPZxncYfwmWUl6JmF52oTv+bgbDeQpkISY/PnQHbbPEUbzqTwDcB5t7cr
         qx++insAeAqfYDHadAJTuYEo+VspRpRHxsDhgYGhgOBI1cNvSCBVyqr6NIT5oPlPEf3L
         XaDQ==
X-Gm-Message-State: AHQUAuY0M/QEfXgvsYU6gyVtZY3B9Ac+j30gNbY6yInvfFvo1//Pi0Zi
	XNAiJdL7ZthMv7lkLGBScwGQ2gGoOEE4wtveKKCBPMGCddlTCkK3sc7puiAjnq4jnFwQRMUAFfb
	WdFppW7uNPjclqx2WNmjIGmV9WLzCu5RP74p7Z0IN0glSgDsANkQ7NWN11qtAzlnuAQ==
X-Received: by 2002:a63:5518:: with SMTP id j24mr4324727pgb.208.1550221062993;
        Fri, 15 Feb 2019 00:57:42 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZH1Ie+ZMBxN6w//BFH1p+dw1KxNRF5ibXqatp1hD8rBhOIcZI3kfqGn/lqIqAE7xWp6k65
X-Received: by 2002:a63:5518:: with SMTP id j24mr4324679pgb.208.1550221062231;
        Fri, 15 Feb 2019 00:57:42 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550221062; cv=none;
        d=google.com; s=arc-20160816;
        b=vRGvUjUJ1DkMp39C/UvP1Io48HfL7MWo5SupP7n6yqxL46ZPHG2uzEOeXRFkVyHIfK
         s+39GGhzhAhmGmnoJ4k2uZnV1YZJIIeOKK680DZ3EBm/iwCeDVOv5kKwKaDiG0LqDIFb
         TvNK/fj7Usxsfd16W7iwKdzugVCKd2eS/98WpJc8WV/67x/JMkHMh2t03hlcOPO8V9dY
         +tAJK0f0r2vB6fVlaJALgGmCboilfLDZgQ4izsWlJj9f0+f+IFz6i9JCw0gJM0EO4oyE
         tzdAj5Raz5A6p80ayangf/VGd1UVPtqTYcnMu9jWsvV8bhOhMDl78M/79ID+kUMtmKXZ
         GIgA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=lC0sJXKkNVKrNcwoJXfFFpIZaHgwwYjVNEpuiQ0lz3E=;
        b=DvFyPJirsPbVOP40OG8svqkWziBaRAsRJ/bU67ut+lDOY/JUlJxzFpvSpJ1o/kdCRB
         Au5L2fyBoAKro5jyO2JxJfqzmzEaE3Tx+HwVpFnn4m9PWOot1To8lueqNV96VS4JkvzL
         cWttvIrLv2NrQymFSBS+rdItJenMJBGkigNhdC2hAq37OGb1i2ayR6SgVMX5oZvzcCS+
         VLeOu7XoPpDDigLmA1953JKitePZ1HDa66T07uHdcWDbVbnILDmAc1F0K5q6RvwMHYlu
         chD3Rd3Dk8Te2SPIxYg0PGjYfWxH+fyigBTANLUSxyweCeFDOb9UFTUjrwCVQ/apvBbD
         jANg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=gT8IzfYM;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id i12si2096308pgq.466.2019.02.15.00.57.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 15 Feb 2019 00:57:42 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=gT8IzfYM;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=lC0sJXKkNVKrNcwoJXfFFpIZaHgwwYjVNEpuiQ0lz3E=; b=gT8IzfYM0rLFTG1VADzNxWfkL
	0eTJScOywY+BgA5bL80r6zjO1AZl0H1zn29CTmFlZpu9sIc1WYqCtNA2bv/sLQy+V7B5KSUJL9kBf
	Mjc3XlxeAS2Al3t6/Whmm/lamblTaQI4AOdXw4EJkWBnRgFshT9ee/IpFzmm8tY1oqVPt1WRJewMQ
	wg8kTdGA4sk4TirfNw88ZtdtbGnDMH45veEYZy1uMspmPpNxOUFG+XJ9YCgDMkUqaGfGURYZIExdP
	N88tGKmHqC9VA5C/vAfXJZLPzY1ecvbeTU9gZV2OI7fGkQGeoFyBBHE8kTs/NXjsX9OU67Bl1b2ZI
	4/Q6jy/xQ==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1guZJT-0000As-Ke; Fri, 15 Feb 2019 08:57:39 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id EE255201A8970; Fri, 15 Feb 2019 09:57:36 +0100 (CET)
Date: Fri, 15 Feb 2019 09:57:36 +0100
From: Peter Zijlstra <peterz@infradead.org>
To: Igor Stoppa <igor.stoppa@gmail.com>
Cc: Igor Stoppa <igor.stoppa@huawei.com>,
	Andy Lutomirski <luto@amacapital.net>,
	Nadav Amit <nadav.amit@gmail.com>,
	Matthew Wilcox <willy@infradead.org>,
	Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Mimi Zohar <zohar@linux.vnet.ibm.com>,
	Thiago Jung Bauermann <bauerman@linux.ibm.com>,
	Ahmed Soliman <ahmedsoliman@mena.vt.edu>,
	linux-integrity@vger.kernel.org,
	kernel-hardening@lists.openwall.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [RFC PATCH v5 03/12] __wr_after_init: Core and default arch
Message-ID: <20190215085736.GO32494@hirez.programming.kicks-ass.net>
References: <cover.1550097697.git.igor.stoppa@huawei.com>
 <b99f0de701e299b9d25ce8cfffa3387b9687f5fc.1550097697.git.igor.stoppa@huawei.com>
 <20190214112849.GM32494@hirez.programming.kicks-ass.net>
 <6e9ec71c-ee75-9b1e-9ff8-a3210030e85d@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6e9ec71c-ee75-9b1e-9ff8-a3210030e85d@gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 15, 2019 at 01:10:33AM +0200, Igor Stoppa wrote:
> 
> 
> On 14/02/2019 13:28, Peter Zijlstra wrote:
> > On Thu, Feb 14, 2019 at 12:41:32AM +0200, Igor Stoppa wrote:
> 
> [...]
> 
> > > +#define wr_rcu_assign_pointer(p, v) ({	\
> > > +	smp_mb();			\
> > > +	wr_assign(p, v);		\
> > > +	p;				\
> > > +})
> > 
> > This requires that wr_memcpy() (through wr_assign) is single-copy-atomic
> > for native types. There is not a comment in sight that states this.
> 
> Right, I kinda expected native-aligned <-> atomic, but it's not necessarily
> true. It should be confirmed when enabling write rare on a new architecture.
> I'll add the comment.
> 
> > Also, is this true of x86/arm64 memcpy ?
> 
> 
> For x86_64:
> https://elixir.bootlin.com/linux/v5.0-rc6/source/arch/x86/include/asm/uaccess.h#L462
> the mov"itype"  part should deal with atomic copy of native, aligned types.
> 
> 
> For arm64:
> https://elixir.bootlin.com/linux/v5.0-rc6/source/arch/arm64/lib/copy_template.S#L110
> .Ltiny15 deals with copying less than 16 bytes, which includes pointers.
> When the data is aligned, the copy of a pointer should be atomic.
> 

Where are the comments and Changelog notes ? How is an arch maintainer
to be aware of this requirement when adding support for his/her arch?

