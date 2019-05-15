Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3943BC04E53
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 15:20:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F3E1120881
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 15:20:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="hwwkkVyu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F3E1120881
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 90A2A6B0006; Wed, 15 May 2019 11:20:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8BB806B0007; Wed, 15 May 2019 11:20:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7A9846B000D; Wed, 15 May 2019 11:20:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 452B46B0006
	for <linux-mm@kvack.org>; Wed, 15 May 2019 11:20:41 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id n4so104156pgm.19
        for <linux-mm@kvack.org>; Wed, 15 May 2019 08:20:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=2jOakzpA8HKNq+MMsYE/nSV1Gu2XO1Vws64soAe0Eko=;
        b=DyUFUDnHqBz0AEYp1OcDwYP6rrKfOIu1QtD/vQWgf4LKLvdNeq2/dYasR9gkHLvC8x
         3wpuJrwTeSvXFcMXjq8/xZD4qwglaeNNaIZ51QHXYhtquaAYZyCT9eYni+Qs7akrV1DN
         4jSLgbLs77ktFXLHLYhCYM1c87FZGmbsgMMVV7HL70Ehmw+mn6+1rwR0ZulNgKtrOncO
         v1aOBXzQaQeLHVA4QuAT44nRIcATTETDihQMwMn+Edlys1/4FnJEFNfi0xyEsOeD4R0G
         m7LSdhp/QeHWuL/ZQKOokloB345FKqwVS9CYwDCUPdff4riBesqkq3mkhftrUaLp/Y2C
         a0uA==
X-Gm-Message-State: APjAAAU0QL1kDLufG5LIngHc5uEvg8LCZFmL25K2a2ODQA+EaGjPcr+S
	2EjiZ7GhsSZaxa2fSuecXjM52LrwMM6qhfEpLXhsqCd723jiev8+m/x2WRtzYBEqlt3ilKJUFIb
	lVMPmgu/NDtd/ZdmEGGoOZOQMAVnvRMoKV39Ha1YLlGPKUJ2hzCOsELK2jze2jWuJOw==
X-Received: by 2002:a17:902:968b:: with SMTP id n11mr44311791plp.118.1557933640906;
        Wed, 15 May 2019 08:20:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyilPKphsboJnu7d1rS5Qu9xwwajLw3myo9QLC1OudhBOAyRfDG8Ul58ZWKWTbDmqZCVaug
X-Received: by 2002:a17:902:968b:: with SMTP id n11mr44311698plp.118.1557933639737;
        Wed, 15 May 2019 08:20:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557933639; cv=none;
        d=google.com; s=arc-20160816;
        b=rHQiwe1CcEzuCz4b/6imIz4wf/8sXNiwMJH79bmd0IHMowKpmDj3DRClw/9tOW6X4e
         DUqrIiZg1G3cWbp2N5FRz1dmTO+uAz+Q+Qya9cn92YiJAbX4jV4JkWpvlXaRLIbpupVv
         WbbohlW5xc4Xn0EsbsayiRgwy6BYRSKkwrXOesrnIK85r8R4npd5Ptis+p9R4MwDrlrt
         Xf30LBECQMQ5pB+HhbVS5upjcg8L1XIyF46Ks51RyD+0H9p434yK0i/4RZuBr4GwZmBk
         jdrmVZ8slIAZt9PyyY7efM6EgFMMw4YmyH/sJByg5eCenSce8BDlv9l3rsKhFCr+1pw3
         Q4AQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=2jOakzpA8HKNq+MMsYE/nSV1Gu2XO1Vws64soAe0Eko=;
        b=SlCKtKiH/0f7JiaHrKowxPIw5flWXZS10kUcFX1N6RD8+ET0aOQI/x3fzlWTLRUXqN
         Rem437nzqqucsGhh+OLcayG1XFYzFHvqdVfWO0eblrmDNila18gDe3qCy7rPXtA5u2Sg
         SP0vn5BA4UIYi2IZN5zy/ov+6i4aW6LxZUArLDu4CuapzGlJl3MGvEA7HKyQMh9KwGh3
         GKHYa9v2y/u6jBFe1W9KVy/W4SitMuoGalvk3u3769m6KR8xlVmr2lVVK0LAJb6ccCTS
         p41KxLaPV5bvneNziRwXy4UCV0fsOwNHDJjIK5BzSxV1qxfH4R5PDSeLIatnq/ZflU4P
         F4pg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=hwwkkVyu;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id w10si1998815pgr.296.2019.05.15.08.20.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 15 May 2019 08:20:39 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=hwwkkVyu;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=2jOakzpA8HKNq+MMsYE/nSV1Gu2XO1Vws64soAe0Eko=; b=hwwkkVyuaLcdnbwQd2fZShmvB
	IvrVb7LY6X+R+frjUuT7TpC4b1FzEjCxx0QoqzwleoMNaGqbqJpGJK2BdtaqJFqqcNIS1m0W3oTmB
	pVM9ErECGTK4io52yDjGq/aXBr+xeiQAatOgNO1bf6JnAHvopKYSr29gfew6ibjVXDELWatWjGoyj
	H0S3BWvLQKDvzsusmplujOJX9mzeuAIYavwj4W7A+z/xRj84uLXxtzEGTasqLQgUKHriszFqSRZFS
	f5L5njCt5zdARgmv6dggXtZQhuyFcxSLR4NAzXcQ+bUJPAMPePX6SQ9pn/HfSWLXTOjSS2/Cec2f9
	pz2eECTLw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hQvhr-0003gl-Rb; Wed, 15 May 2019 15:20:35 +0000
Date: Wed, 15 May 2019 08:20:35 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Lech Perczak <l.perczak@camlintechnologies.com>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Eric Dumazet <edumazet@google.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Piotr Figiel <p.figiel@camlintechnologies.com>,
	Krzysztof =?utf-8?Q?Drobi=C5=84ski?= <k.drobinski@camlintechnologies.com>,
	Pawel Lenkow <p.lenkow@camlintechnologies.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: Re: Recurring warning in page_copy_sane (inside copy_page_to_iter)
 when running stress tests involving drop_caches
Message-ID: <20190515152035.GE31704@bombadil.infradead.org>
References: <d68c83ba-bf5a-f6e8-44dd-be98f45fc97a@camlintechnologies.com>
 <14c9e6f4-3fb8-ca22-91cc-6970f1d52265@camlintechnologies.com>
 <011a16e4-6aff-104c-a19b-d2bd11caba99@camlintechnologies.com>
 <20190515144352.GC31704@bombadil.infradead.org>
 <20190515150406.GA22540@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190515150406.GA22540@kroah.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 15, 2019 at 05:04:06PM +0200, Greg Kroah-Hartman wrote:
> > Greg, can you consider 6daef95b8c914866a46247232a048447fff97279 for
> > backporting to stable?  Nobody realised it was a bugfix at the time it
> > went in.  I suspect there aren't too many of us running HIGHMEM kernels
> > any more.
> > 
> 
> Sure, what kernel version(s) should this go to?  4.19 and newer?

Looks like the problem was introduced with commit
a90bcb86ae700c12432446c4aa1819e7b8e172ec so 4.14 and newer, I think.

