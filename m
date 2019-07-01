Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B8D92C0650E
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 10:15:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 79E0C2133D
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 10:15:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="sP19+PAp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 79E0C2133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 153406B0007; Mon,  1 Jul 2019 06:15:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0DCCB8E0003; Mon,  1 Jul 2019 06:15:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EBF918E0002; Mon,  1 Jul 2019 06:15:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f208.google.com (mail-pl1-f208.google.com [209.85.214.208])
	by kanga.kvack.org (Postfix) with ESMTP id B445A6B0007
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 06:15:17 -0400 (EDT)
Received: by mail-pl1-f208.google.com with SMTP id 59so7065772plb.14
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 03:15:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Qumezaw37/cTrpldxU/NR0/64blhcx3tr4wsv/lBDY0=;
        b=cfitnMbmq+8oeQCAvsIYC0Oy4VnsetkwKge9Bu4hPK2RJ1E0sOH7qzkWERw1X8+HOQ
         WrCzaMoNlKetdl7YcRNDa/gRxVI2O2l81b6BX9bYPzrg93MpeElhQZRLwHbjssP+hml4
         sqQenHaFFPSYkfhxK67rz9eVRNdvLfnZ0YD4N6ztU2JqwnDTDwls5tDweoYSYsEFeUz5
         v8NolDAOCcfFNZbKEDPG3sLSwszqiJUbLbpG6Wds4djdQ/7wkEe5KvEj/JeoUFQGBRNu
         1yLfkdU9e0WDQ5vk68sGq5TvWXe3GvcYFqS+5EGJborjXDfm1Od8zIDTQHQklxAhqHuQ
         Ku+A==
X-Gm-Message-State: APjAAAWoESwS6OeM1EqHBzk4n+jA2V72YDAR5FzNRZSg3fscAwpXu9GG
	wzhjavClI8KOUOKQ5qUlo5Xb1PUuYY1xaep4uo4SbGWNVKju9/qDWSUguTaIdXoHBKizAbSSK61
	iHAkrAqfXT5risXMfJP+w0YIfMbnaUQh7ABw+rv5H7LcUgHaf83Eypa9p0IPkLARVgA==
X-Received: by 2002:a17:902:7041:: with SMTP id h1mr28120617plt.133.1561976116946;
        Mon, 01 Jul 2019 03:15:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz98NdQHdohzILaYhWW/aj5y1CTU6edF8wXZOoqpHWWfKsw1GqXNE8rXjfhce+wHmNguNBT
X-Received: by 2002:a17:902:7041:: with SMTP id h1mr28120564plt.133.1561976116317;
        Mon, 01 Jul 2019 03:15:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561976116; cv=none;
        d=google.com; s=arc-20160816;
        b=NyZcNslK6RoEr7ov01IGZOkM4d+UZEvSTMO082/b3ahUlkmdT6hU+pn2AzhtgxJduX
         SKkRzEpkYqBZDPAOn2YTEvyhMOmBNObQsrn/g8L30AkJyz8UfpYR6qYgFSzehUi7+UCb
         k1qOwRDQQKzarp6RDOSz0cpvGNtvOgofH4yvMxNqFekI7HLDvJkl8qKQyRLQQx5ssG7H
         hgBFJsRh05TU1ws3OK+NzQOktz1tvyfvDDRAbxiwu9reGhLcYvcep2p6ANRj0NK02wcm
         0TvLxXcnhxO2ReLxOafgTdPfqWSL5GdNzgp/f9qGhU5kAta+EdINiUi1N2P2qv6V23Dx
         Mwog==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Qumezaw37/cTrpldxU/NR0/64blhcx3tr4wsv/lBDY0=;
        b=s2236Qe40oDvZrqvqpCq4ycu4d/9jHJ1jhS/f0wxPxMMWh1z//bQ3E1b0AQ9ITCMpw
         avNC+lIMV947KkdFm63sYt+iUl+xFj1MmnFSoUTCgkk1bLSBl2n4GDMaePJ9t3Bg4Z1m
         I87r0WhP310rReTl98mydZMtgiA3XXsqT7PoB/6U7SMjEZZALhSbBHcYCmM/c1g+Z6lS
         QB6KAECSG9+Lm36Aj6ENxjuJQFbOscKUqGOm0QlEF3e7+VvCIw6tOyd9XUXTsOZzh2Yn
         0B+1VR97qyKtGUMMvPl/wtLPBOx15JPZHtXAGFTtproiZ/aEhpK2Qq9zPtqeknwC8L9g
         g9Mg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=sP19+PAp;
       spf=pass (google.com: domain of will@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=will@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id j17si11176523pfn.278.2019.07.01.03.15.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jul 2019 03:15:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of will@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=sP19+PAp;
       spf=pass (google.com: domain of will@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=will@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from willie-the-truck (236.31.169.217.in-addr.arpa [217.169.31.236])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id E4D9B2089F;
	Mon,  1 Jul 2019 10:15:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1561976116;
	bh=BmE0pK+B/9WbeNo5hd8jhUkYwvz6tMUWGRtqHWxTqgc=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=sP19+PAprJCKT1vB2Suu5r3ulKn8GQeG57tpiJg4Kq6zGPN+/cs009iqz4lq9XT8P
	 aS/2Xw+qDBagxlS3Sg9TyU3BpqemUimAwUvQ74vmxYe9LmJI/U6wQXOt9has6j0+4+
	 jlBkGuGr5Sr7XbAj39iTiIYD3i4UfJv49TwVkpuU=
Date: Mon, 1 Jul 2019 11:15:10 +0100
From: Will Deacon <will@kernel.org>
To: Steven Price <steven.price@arm.com>
Cc: Nicholas Piggin <npiggin@gmail.com>, linux-mm@kvack.org,
	Christophe Leroy <christophe.leroy@c-s.fr>,
	Mark Rutland <mark.rutland@arm.com>,
	Anshuman Khandual <anshuman.khandual@arm.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Will Deacon <will.deacon@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linuxppc-dev@lists.ozlabs.org, linux-arm-kernel@lists.infradead.org
Subject: Re: Re: [PATCH 1/3] arm64: mm: Add p?d_large() definitions
Message-ID: <20190701101510.qup3nd6vm6cbdgjv@willie-the-truck>
References: <20190623094446.28722-1-npiggin@gmail.com>
 <20190623094446.28722-2-npiggin@gmail.com>
 <20190701092756.s4u5rdjr7gazvu66@willie-the-truck>
 <3d002af8-d8cd-f750-132e-12109e1e3039@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3d002af8-d8cd-f750-132e-12109e1e3039@arm.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000003, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 01, 2019 at 11:03:51AM +0100, Steven Price wrote:
> On 01/07/2019 10:27, Will Deacon wrote:
> > On Sun, Jun 23, 2019 at 07:44:44PM +1000, Nicholas Piggin wrote:
> >> walk_page_range() is going to be allowed to walk page tables other than
> >> those of user space. For this it needs to know when it has reached a
> >> 'leaf' entry in the page tables. This information will be provided by the
> >> p?d_large() functions/macros.
> > 
> > I can't remember whether or not I asked this before, but why not call
> > this macro p?d_leaf() if that's what it's identifying? "Large" and "huge"
> > are usually synonymous, so I find this naming needlessly confusing based
> > on this patch in isolation.
> 
> You replied to my posting of this patch before[1], to which you said:
> 
> > I've have thought p?d_leaf() might match better with your description
> > above, but I'm not going to quibble on naming.

That explains the sense of deja vu.

> Have you changed your mind about quibbling? ;)

Ha, I suppose I have! If it's not loads of effort to use p?d_leaf() instead
of p?d_large, then I'd certainly prefer that.

Will

