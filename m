Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E7196C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:02:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A7DDD2183F
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:02:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="rAymWQyw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A7DDD2183F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3F7CF6B0006; Wed, 27 Mar 2019 14:02:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3A86E6B0007; Wed, 27 Mar 2019 14:02:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 272C56B0008; Wed, 27 Mar 2019 14:02:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 033106B0006
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 14:02:32 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id x58so17716167qtc.1
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 11:02:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=I5uALa7MVL7UzXPrEYcYU1Dm9p2rPQBrM3MAs5UYgj0=;
        b=lhco6IazXMzFCSqN8j+XtSN4HodVJcEftmM4GzkZqU8QkiJySEL6DXbmrT1ZpQQqH0
         H/S5xmh2yK+N/UVKth0SEmkaJbjyI83C753TXsktPM9XvGxWp6KNbtTCTiN8dfRrqECD
         5rbKmDCsueZemhsIZF/Q7yPy/LVaH83pLHhcrDaXQ27Lr1BCIzSotuFLTuZI0/uI9bPh
         OBD5ygO/dCl3Ufcbl1Afgm7yhfwvamsFvYlz4YiWA1SR8RdrWsjFc0u+YhVgKCYMdeWz
         b5ghfWMIaYFlFjaiTWPIzJWUQgeGF2bi5/r3leiEvp13pjm0WpgE2U/LYzBXwx+PrvmG
         u/8Q==
X-Gm-Message-State: APjAAAVi/xcETbJPaFESQ14nDmAwemBokn1pCeFtulFWDhmrCrzl3emJ
	qHErr5ANHRYtVePrHKJ8u6zd/MCpXKPnjHeTcZBawYvGUOgtzv4MlxXEqKUGTdi83aPWRZUbpcx
	kiUsTYNQXD5M/zjT61mXBwRefkll0IGVNwjhg2N3LH8jIQAw9Sgilc83zHYI2EiE2fA==
X-Received: by 2002:a0c:d06a:: with SMTP id d39mr30190898qvh.182.1553709751779;
        Wed, 27 Mar 2019 11:02:31 -0700 (PDT)
X-Received: by 2002:a0c:d06a:: with SMTP id d39mr30190838qvh.182.1553709751129;
        Wed, 27 Mar 2019 11:02:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553709751; cv=none;
        d=google.com; s=arc-20160816;
        b=djz433+407XLy0TtTN+dtIvtVKRUyztKtA/lJJzd9rxG8FIPAgry1hA5G2HyhYW7G2
         BSeHnFZHjTKuBEGdexxhGEwp/Mm7Fge2Uhd9BN3UBLcHYxB4+N6d1mem7kFfbmcRpWYr
         EKk7zfwYizzGKvgVUg4D8H0TFUhMBMR89xgCqNrO63BZHcf+gyTjbN+iXjN34SwQMGK+
         k9czMEMf0n8Ipy5qLTtiqjJo511m9JY3v/panty07g/EJqzZSzcjeXj3w2vulyd+Imqq
         tsvs9s0RnEmsRF+ze8gRIQbde8OuTCHJYOmuUi/DcaRlAOskC3N6A5UtCDXD3TC/G8Uh
         EUYw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=I5uALa7MVL7UzXPrEYcYU1Dm9p2rPQBrM3MAs5UYgj0=;
        b=hLp4hbVFT9znP4k9k6YvwagGN6zyE6RT9NSnAe3Wk2lV+3kY+k5YC0a11iZXm9BL4Z
         j326BfC2gY2m5egAg20Srdqu+I+HKOodZRvB6xsl29acOYV/bJcr288/SFEsSbW4eHAq
         /2iaI4ginsLTMUBkNIqWmsMdwN+z9GS/CG63u+xDNYBILvWZADsR+CCcCYlnBKbKHcvu
         rAOCkbCivv9IvmnqenB0A0U53rw9frOJodj7eOu2HLploRwwJfSdHx6oXIq5jqPji8cS
         UZWczJrsixxwpfeonbdm6ynu4zP0gIX36T/6qGJk+PJNT/sQAqmBCbnUQDWMw6gksVZb
         NRLQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=rAymWQyw;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q20sor23320973qvc.68.2019.03.27.11.02.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Mar 2019 11:02:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=rAymWQyw;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=I5uALa7MVL7UzXPrEYcYU1Dm9p2rPQBrM3MAs5UYgj0=;
        b=rAymWQywHAL6cGuLPbwZYc6GHPnzTva6JXMImf+l/QA6vsyiRM3ITgughd+S5T/UST
         twIk0RyODDDlWDX2xDRPkJTuSD5Irmpn9hUlDRrCR4c/V+zQPURL77c4T7YCGiZE7NlJ
         9GDZAIkTR9Jy7Yu4QVQyfl9a9fRNdg7g6eJU+vwJTuAw1MUt/xuplZ8b2Wuw98TiKo6+
         DoGtFDjkJ1D4WgXowI27QJwWZI6wtOIeWP1thglRkPdAXo7gw06gS4M6VBjixhWxmc9w
         K94yUTVqfA/uaj3tAMKUZhgPM+h1DeBVU4jayX5ZDwiLco6oWSbrtXQoJtwWoOkykTqO
         NZdw==
X-Google-Smtp-Source: APXvYqxSvtALFnQF+jYQ/t44NY6L3IdneTFfmE4na1KaS1YumXhbcc8Kb66nN5Yz+mR4IiaolNEoEg==
X-Received: by 2002:a0c:d2fa:: with SMTP id x55mr32627047qvh.161.1553709750897;
        Wed, 27 Mar 2019 11:02:30 -0700 (PDT)
Received: from ovpn-120-94.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id j5sm776085qtb.30.2019.03.27.11.02.29
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Mar 2019 11:02:30 -0700 (PDT)
Subject: Re: [PATCH v4] kmemleak: survive in a low-memory situation
To: Catalin Marinas <catalin.marinas@arm.com>,
 Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, cl@linux.com, willy@infradead.org,
 penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <20190327005948.24263-1-cai@lca.pw>
 <20190327084432.GA11927@dhcp22.suse.cz>
 <20190327172955.GB17247@arrakis.emea.arm.com>
From: Qian Cai <cai@lca.pw>
Message-ID: <49f77efc-8375-8fc8-aa89-9814bfbfe5bc@lca.pw>
Date: Wed, 27 Mar 2019 14:02:27 -0400
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.3.3
MIME-Version: 1.0
In-Reply-To: <20190327172955.GB17247@arrakis.emea.arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/27/19 1:29 PM, Catalin Marinas wrote:
> From dc4194539f8191bb754901cea74c86e7960886f8 Mon Sep 17 00:00:00 2001
> From: Catalin Marinas <catalin.marinas@arm.com>
> Date: Wed, 27 Mar 2019 17:20:57 +0000
> Subject: [PATCH] mm: kmemleak: Add an emergency allocation pool for kmemleak
>  objects
> 
> This patch adds an emergency pool for struct kmemleak_object in case the
> normal kmem_cache_alloc() fails under the gfp constraints passed by the
> slab allocation caller. The patch also removes __GFP_NOFAIL which does
> not play well with other gfp flags (introduced by commit d9570ee3bd1d,
> "kmemleak: allow to coexist with fault injection").
> 
> Suggested-by: Michal Hocko <mhocko@kernel.org>
> Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>

It takes 2 runs of LTP oom01 tests to disable kmemleak.

