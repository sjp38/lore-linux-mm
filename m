Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 01ED7C43381
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 04:41:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B593D20651
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 04:41:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B593D20651
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4A4B26B0007; Tue,  2 Apr 2019 00:41:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 453B76B0008; Tue,  2 Apr 2019 00:41:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 344766B000A; Tue,  2 Apr 2019 00:41:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id F232E6B0007
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 00:41:31 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id f7so1322773plr.10
        for <linux-mm@kvack.org>; Mon, 01 Apr 2019 21:41:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=jVaQRIMwgXdbDZWprpsYiL3hhteVrFSuWgZpVcatz8E=;
        b=L/nk3FE+fbp/JoLzp8o7jElDbsDShqyZUjuO6p9xH5oQyx43Xw4ZSiD/Bmds6DF0lF
         aZy801Tp38SDDJcPEhs4wZbvt+Hq4YX+PppdjhuAmozi6hhnYQnSFpHkQ3kOnOdcoh3c
         Y0h+fQ3fhskIOJ0S33mJx29K8zlLSR2RKTeEmibqqEwbk805ynJjA0vIbvpEH82+ZanM
         dSeNCkQ2U0E/9i0wrvH3P4tboRwb/KMv2yY50SU68qaTDvDlNFeXgAPs9vL0xBWZF4aB
         hV90FLFb7o/YQjyCO9KM0RwHuFqMs4bp/8G8IwA0CExlW1oMySfW89cH/bh4h9jlQNMG
         g7wQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAWiuXLnH7DvtU6YnTNil2/atmg1mM2Lr68P9moudSGtX6GlgKnW
	u2vP6/ccl9y5KweCE3ZpHDoY5XlwMxY8V2x48cx1PoDC0xCvRe95T18NKauq0QiXk5sa6bx2TBH
	xO6JRi+He0+cZWxUswfYV9TCqDPZrUEYoKR0/81x5nEnrg7HbpGjNkux3NMSzrbGgMw==
X-Received: by 2002:a63:450f:: with SMTP id s15mr63664288pga.157.1554180091530;
        Mon, 01 Apr 2019 21:41:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzSXIowz966bdUdmIocETkS32MfNAWbv8/lm1kIhd2x/XlJNhLUyQIw9T1TvLSeFZUVqcCN
X-Received: by 2002:a63:450f:: with SMTP id s15mr63664251pga.157.1554180090657;
        Mon, 01 Apr 2019 21:41:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554180090; cv=none;
        d=google.com; s=arc-20160816;
        b=q8yibM1CDjywyhOU+xsweO57diYIQqwJt9JDcQV/yCowUcUnOuvYZcACSzWtTGofpL
         yrN9RXvs8y/iXATlYMSbJ6ivt+ZVm6uQg7OVcmUjTWsNd5TF7QTqF2R8Fx1c+52P0AEY
         sBu7EigkoJy7P2HLwvi6OfkoQqcc/1UuANpkus14F+8ZRicufSQMdPg/1QdMeSE229Oi
         HM2t+peEzVvgA8UmYRIXVjJ+dAmfeoJL7j+Tyzpg4JV4+X3/SLKYsCfdCDLQMfm9bIds
         4WXeMvGBqfTWYRipBe10ErU1qf25wjixg0m4GaxrnimB0RGJxp76xKOADlhl6937UKKW
         z+sA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=jVaQRIMwgXdbDZWprpsYiL3hhteVrFSuWgZpVcatz8E=;
        b=fAVK+eXwdiEkIqdYeKIgYjK4nLlYngZkMdIgKBN+sVGYV5x/Nb2N+o8lTOhaOIKkkF
         sDwP2SOW2jhH5d709OWgaYO7CIjT5kjLr3dtwcDMzknOu5cGoi9K0J92BEvW4E0yCobU
         e5RQbC8cdJUTBFyo6PCe4fpiGxnpYfeXcIJ51g95EXLGQCGSN634FqhDOP0xszn28d42
         5TwJqWYWjAIavwsyGG2bLNb96QGm3PipImsP9L7EIGZypH5jT3b8K1uK8SVTy2sJA14p
         k1AxL0J7r9ciKQ1YJVUyQclRneZpMStDUErUggJ6W6B4NbaEU8ipEDpSku79YpAm0GKX
         LS3w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id r10si9963803pgp.30.2019.04.01.21.41.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Apr 2019 21:41:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id A4A47CAF;
	Tue,  2 Apr 2019 04:41:29 +0000 (UTC)
Date: Mon, 1 Apr 2019 21:41:28 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: "Tobin C. Harding" <tobin@kernel.org>
Cc: LKP <lkp@01.org>, Roman Gushchin <guro@fb.com>, Christoph Lameter
 <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes
 <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Matthew Wilcox
 <willy@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 kernel test robot <lkp@intel.com>
Subject: Re: [PATCH 1/1] slob: Only use list functions when safe to do so
Message-Id: <20190401214128.c671d1126b14745a43937969@linux-foundation.org>
In-Reply-To: <20190402032957.26249-2-tobin@kernel.org>
References: <20190402032957.26249-1-tobin@kernel.org>
	<20190402032957.26249-2-tobin@kernel.org>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue,  2 Apr 2019 14:29:57 +1100 "Tobin C. Harding" <tobin@kernel.org> wrote:

> Currently we call (indirectly) list_del() then we manually try to combat
> the fact that the list may be in an undefined state by getting 'prev'
> and 'next' pointers in a somewhat contrived manner.  It is hard to
> verify that this works for all initial states of the list.  Clearly the
> author (me) got it wrong the first time because the 0day kernel testing
> robot managed to crash the kernel thanks to this code.
> 
> All this is done in order to do an optimisation aimed at preventing
> fragmentation at the start of a slab.  We can just skip this
> optimisation any time the list is put into an undefined state since this
> only occurs when an allocation completely fills the slab and in this
> case the optimisation is unnecessary since we have not fragmented the slab
> by this allocation.
> 
> Change the page pointer passed to slob_alloc_page() to be a double
> pointer so that we can set it to NULL to indicate that the page was
> removed from the list.  Skip the optimisation if the page was removed.
> 
> Found thanks to the kernel test robot, email subject:
> 
> 	340d3d6178 ("mm/slob.c: respect list_head abstraction layer"):  kernel BUG at lib/list_debug.c:31!
> 

It's regrettable that this fixes
slob-respect-list_head-abstraction-layer.patch but doesn't apply to
that patch - slob-use-slab_list-instead-of-lru.patch gets in the way. 
So we end up with a patch series which introduces a bug and later
fixes it.

I guess we can live with that but if the need comes to respin this
series, please do simply fix
slob-respect-list_head-abstraction-layer.patch so we get a clean
series.

