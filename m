Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 64F2DC32754
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 02:46:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EFAE42171F
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 02:46:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="WaAJIxvx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EFAE42171F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4E3246B0005; Thu,  8 Aug 2019 22:46:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 492336B0006; Thu,  8 Aug 2019 22:46:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 380186B0007; Thu,  8 Aug 2019 22:46:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 01F2D6B0005
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 22:46:55 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id e25so60481546pfn.5
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 19:46:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=k9ysUCj8sFdxJhtdA1rA7e9UmHUPqdKijogVrakBrS8=;
        b=WrdAxYVOixQJmEtYk/Kxv1cCbRoB41elZqsbpERzBW+F65sGrGi2aELQVg8pI4ycgR
         GVZo4kD3axkQBJkEUg1CzdssFu/wcQQSu7bXJxJ7kchtgUSrSyC/Y1CjH+CaBx5f1Kkn
         JYFUAayM/q6bbbJIiRtsbXnvIttB+LhRxdcyHxCw+5CUd0lY/pR/fmYWOyqBjHWVIQfr
         ZJaHK6/YHQSExfhXiL9GItxW/IGxLXTUuorqHDO8FBWzqf05o6SBQpnCYO1tBwF0UIJh
         pJXVN1aqC5RSZczXyRi48D/X/RyHMjrzqJP2wdQOw5oJuN5e9lIt+Du8LDH10zv29NbJ
         2hmw==
X-Gm-Message-State: APjAAAWFPskGRLPnqliaex5tkBp6xkkF+q0XezafU8nVW8d2ec+OCsor
	yN8HHuw2QFY//KFgJ0VoNbew24aRW+rzCqPZGAmaxfjJY6PchTapazs0tWnFKXtMCdTQKlUNT3Q
	/uII/30F26mGSCKs4peMYnV738ZfNPzycGvRyIJCC2CnES6crQDriRncg3pHAZPDfYA==
X-Received: by 2002:aa7:83ce:: with SMTP id j14mr18634074pfn.55.1565318814538;
        Thu, 08 Aug 2019 19:46:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzwpOpmVN2VEM9vlenRSGfuW1/6Ws7Juc4aUEvJmGqKcpcY8eLosaNiyG1NgrQARvKGa2fs
X-Received: by 2002:aa7:83ce:: with SMTP id j14mr18634013pfn.55.1565318813406;
        Thu, 08 Aug 2019 19:46:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565318813; cv=none;
        d=google.com; s=arc-20160816;
        b=cTCbNv5j7y21bBj8OflhYtpEs4fF51IR84aYz4mXiqW+hcXFlub1CjLwHW37J6wNh+
         cVTn4saqgZlM3JalRGoy3D7GcwapB9b2memm7U/P78Z4SWCkPFk3XMydpIOtNlq+9BSI
         P3/bFa0ymdgAQ4qLmkwtqI9rd5sp4lhTTGdIkFvxXFz8R4Gr+/rIxrqi2GERe5Xx8TxP
         1peSQ3Zn0LxrmDCmvVSe2v9W7fTghRW05s6qgxW1yuqLeQbnrpZEI6iMERSVu8M7kOBd
         nrZL1II/G4iZd65No4jK38lHEdITbk37yNJcaFQv4PZfdy8QqkTsQZUz35DTwWbvwHq4
         y4DA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=k9ysUCj8sFdxJhtdA1rA7e9UmHUPqdKijogVrakBrS8=;
        b=X6bAw23cds0to1mCgqp3FB0a81S97fj5V7ug0HDA+DMmutoz9akgG1w9zHIO2Y/2a1
         u+gGUbFE7OTn4Wj8bh/GQiFXAeaGR+vkvhzrSLJtPKG1zIuvJFpxGnHyEDY5crYTtccM
         LuzI1ir9THCRRvye6as+Guwuc30lq7LiUxRCX578gFECGe/ncoBp85RZy2yqRCtMe1bD
         jGYkiPeQRojWsWPQ+C6UtieDTK3ErP67ixAJktztLMwX6l5p5UR2sSvfGZB8FNiFCgnL
         PwASJBfkw13zEsLRJ/hOnjIpHQ7yb1Ot4l806tdXoh5uCCBLZ/I8SY6vmiC1Ckw4HPy0
         m1+Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=WaAJIxvx;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id h63si3236303pjb.106.2019.08.08.19.46.53
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 08 Aug 2019 19:46:53 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=WaAJIxvx;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=k9ysUCj8sFdxJhtdA1rA7e9UmHUPqdKijogVrakBrS8=; b=WaAJIxvxqLMJwq4r0MuB186tS
	eB35TdZihw8we7T+6rzfXNcdc1BFrSHTsICCgF9IYxPFMXnH51MOTuYcDuzIEQFJTMbpdZHz7kU4l
	1gXCVm3zmGNat8g+4gEFOmlEJuABJAdswqsBLhwukirmbwfQV0VJh1UOgKcKX0IHlCnqa9ftb3GN5
	anKRc6DAtdHrlXV80dZ8UTLKLtWWw6siF34Vuvs30NBWsAIUoDuZlJjPXL5Z3iyVaI9c8MyiBg6a+
	ZzMgnF9fEFZkYUNsrMbPcS0zzVnVA5rZwBUyx3/flkMtA4BlYIqbgSIAqMmX6Ch8YNSw7wcyQUOQo
	SWWUHUk+A==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hvuvU-0008Bg-Kn; Fri, 09 Aug 2019 02:46:44 +0000
Date: Thu, 8 Aug 2019 19:46:44 -0700
From: Matthew Wilcox <willy@infradead.org>
To: miles.chen@mediatek.com
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, linux-mediatek@lists.infradead.org,
	wsd_upstream@mediatek.com, "Tobin C . Harding" <me@tobin.cc>,
	Kees Cook <keescook@chromium.org>
Subject: Re: [RFC PATCH v2] mm: slub: print kernel addresses in slub debug
 messages
Message-ID: <20190809024644.GL5482@bombadil.infradead.org>
References: <20190809010837.24166-1-miles.chen@mediatek.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190809010837.24166-1-miles.chen@mediatek.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 09, 2019 at 09:08:37AM +0800, miles.chen@mediatek.com wrote:
> Possible approaches are:
> 1. stop printing kernel addresses
> 2. print with %pK,
> 3. print with %px.

No.  The point of obscuring kernel addresses is that if the attacker manages to find a way to get the kernel to spit out some debug messages that we shouldn't
leak all this extra information.

> 4. do nothing

5. Find something more useful to print.

> INFO: Slab 0x(____ptrval____) objects=25 used=10 fp=0x(____ptrval____)

... you don't have any randomness on your platform?

> INFO: Object 0x(____ptrval____) @offset=1408 fp=0x(____ptrval____)
> Redzone (____ptrval____): bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb
> Redzone (____ptrval____): bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb
> Redzone (____ptrval____): bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb
> Redzone (____ptrval____): bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb
> Redzone (____ptrval____): bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb
> Redzone (____ptrval____): bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb
> Redzone (____ptrval____): bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb
> Redzone (____ptrval____): bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb
> Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5
> Redzone (____ptrval____): bb bb bb bb bb bb bb bb
> Padding (____ptrval____): 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
> Padding (____ptrval____): 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
> Padding (____ptrval____): 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
> Padding (____ptrval____): 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
> ...
> FIX kmalloc-128: Object at 0x(____ptrval____) not freed

But if you have randomness, at least some of these "pointers" are valuable
because you can compare them against "pointers" printed by other parts
of the kernel.

> After this patch:
> 
> INFO: Slab 0xffffffbf00f57000 objects=25 used=23 fp=0xffffffc03d5c3500
> INFO: Object 0xffffffc03d5c3500 @offset=13568 fp=0xffffffc03d5c0800
> Redzone 00000000: bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb
> Redzone 00000010: bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb
> Redzone 00000020: bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb
> Redzone 00000030: bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb
> Redzone 00000040: bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb
> Redzone 00000050: bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb
> Redzone 00000060: bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb
> Redzone 00000070: bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb
> Object 00000000: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> Object 00000010: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> Object 00000020: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> Object 00000030: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> Object 00000040: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> Object 00000050: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> Object 00000060: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> Object 00000070: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5
> Redzone 00000000: bb bb bb bb bb bb bb bb
> Padding 00000000: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
> Padding 00000010: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
> Padding 00000020: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
> Padding 00000030: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
> ...
> FIX kmalloc-128: Object at 0xffffffc03d5c3500 not freed

It looks prettier, but I'm not convinced it's more useful.  Unless your
platform lacks randomness ...

