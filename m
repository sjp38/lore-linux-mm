Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 94AD1C10F05
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 16:00:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3938D2070D
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 16:00:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="LlsVT94n"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3938D2070D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C86906B0007; Tue, 26 Mar 2019 12:00:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C36C56B0008; Tue, 26 Mar 2019 12:00:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B4D6F6B000A; Tue, 26 Mar 2019 12:00:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 940F06B0007
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 12:00:52 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id x12so14000614qtk.2
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 09:00:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=5JSh85fk4kA2upwixVG2YsNhFipIv7bLyOUQWqffPOg=;
        b=R5RzKC5o6J9+HZsf0l/f8YBhtJU7axNGC7JtqsD31mS1h1QOyL/dXoG6B/d2NvpSoz
         HbMcBfrUtbZKmEkaYYW2huLTsH+oThh9zG+ButEjZcQqcMlwQOwciUvW7+GEkVYKGT3U
         fj6mRatBmtUOyoL3hkhOberGLw8NQBm0CYZgymaO1l3QFZOWONvAvXtrQGMOsr7A/g6P
         ZSgc53nlLrYGO4PggVKLlJS+QlAJmqqILGxX7a7HwGAeYuALy4n3lqqWJUEsYpO2xXDq
         V5B6WWfKfwFDmj6gAFEVMHSkiCptTNH6MpnmhFM8+iIRJLIiZPPSCoOA+CSJbInSj0gM
         30wg==
X-Gm-Message-State: APjAAAXMv8KhTY1sNDQFzYdHB054phftsx2K118IhwN/P27EgMnNhYIG
	ddGmTArluv99LazTY+U1fl7OL1L/cVwyWTGirdoGFcdSfE5CJUtzVDcDxD+AW1/1Uky2f6MgXkT
	qM5nwzXcXE+eKxAAutiS06gIN94apipTbzvIPP5Tx14mKRlQl5UDbNJZD/YlVvbM=
X-Received: by 2002:a05:620a:16b4:: with SMTP id s20mr25415626qkj.101.1553616052408;
        Tue, 26 Mar 2019 09:00:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzfjvsLpVQgHTP/+SIIWju2ALnvkRMR7m8I8M5pK7S+q6WfpNSA3OQruTrYKwfxQlDvO+mA
X-Received: by 2002:a05:620a:16b4:: with SMTP id s20mr25415511qkj.101.1553616051196;
        Tue, 26 Mar 2019 09:00:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553616051; cv=none;
        d=google.com; s=arc-20160816;
        b=BfgRDig04BtIxoaX5vA2FJZxk35V/4Rc/4pYhr5QzzSgLa59WDT8jtmpapHxw9t4Ci
         zTW2yaMs8ZNfR0z3lvvAGC7QooRUGkQ1J+UiHtTNJ0ZG2kFc9ObilmS8ZYKg9Li/YD8I
         PWlP/RC5+nUOYdI5npLpSJ2CUTyEdNpKBs/5/lZU11g/pHt0z+ncPp1qWIcH/yP3yrck
         jugJSyKCyRUk2oV7WNrq77FWyGCRxDRNCI1fjYKO1bGl27ZXgsX1MdXdVIFh8GsAsOSG
         ts8Yf0Zeo8Kkqh1T1mpIUx3XbYLvyreOSOJ5jVYxiAaWQtvBFxNNvBYvSLG+X2GfXp5a
         ZivA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=5JSh85fk4kA2upwixVG2YsNhFipIv7bLyOUQWqffPOg=;
        b=olH2yhMmpm98Eeyk2vjR6DPXWS2zZqhtxwZU2xOk7iSqTGS3PJbzkGN53L0NLrF88t
         wVSz4ZRGlNgyGK9IGKqZbxQxE1zv6gg6b70EHYc1xGB4pKQIXrL1OzZvwHHycDaJmfKc
         bcOwJNA7VHVXZjdEalXR3nbbmJOJxOTvtEN1bACkUXQ2VhrRsw09klXLKF56Iv1QLxBo
         v0bRuXo11kEzvfsGFd5kYPQfhaR2S8F3fOAnQHV25xD1dfMLbBFMGHWOPOxMvVvaycvW
         1er+LvWxEOEwhuPic7jCbMLAO+pDqWaKCMVbbuD0Iv359oJYGemb1VqWblPohC8b83J7
         BPnw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=LlsVT94n;
       spf=pass (google.com: domain of 01000169babb99b8-b583bf57-5104-45b7-a4d6-e7677c64ece2-000000@amazonses.com designates 54.240.9.99 as permitted sender) smtp.mailfrom=01000169babb99b8-b583bf57-5104-45b7-a4d6-e7677c64ece2-000000@amazonses.com
Received: from a9-99.smtp-out.amazonses.com (a9-99.smtp-out.amazonses.com. [54.240.9.99])
        by mx.google.com with ESMTPS id h9si1945853qkg.35.2019.03.26.09.00.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 26 Mar 2019 09:00:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of 01000169babb99b8-b583bf57-5104-45b7-a4d6-e7677c64ece2-000000@amazonses.com designates 54.240.9.99 as permitted sender) client-ip=54.240.9.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=LlsVT94n;
       spf=pass (google.com: domain of 01000169babb99b8-b583bf57-5104-45b7-a4d6-e7677c64ece2-000000@amazonses.com designates 54.240.9.99 as permitted sender) smtp.mailfrom=01000169babb99b8-b583bf57-5104-45b7-a4d6-e7677c64ece2-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw; d=amazonses.com; t=1553616050;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=s/y64a9Nl0E1aNUlGJcS6EovFAznUXKfgfzvkfl1KBk=;
	b=LlsVT94ndQ0NoNjRQgTIrVbjQxe8YzPsYuPiQpjKIJZtSBFGGpwhN3YnGRKaH4L1
	pvVtFPrksLbz5+CNWyzLImAaHw9X8AF1fkzV9rY3g01W9wiQM0Yqol3Ecy7XczT/96x
	BijQyM6zrcywzsOmTcDE2iCoQwNvJsZlJVDeJH+Y=
Date: Tue, 26 Mar 2019 16:00:50 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Qian Cai <cai@lca.pw>
cc: akpm@linux-foundation.org, catalin.marinas@arm.com, mhocko@kernel.org, 
    penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, 
    linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v3] kmemleaak: survive in a low-memory situation
In-Reply-To: <20190326154338.20594-1-cai@lca.pw>
Message-ID: <01000169babb99b8-b583bf57-5104-45b7-a4d6-e7677c64ece2-000000@email.amazonses.com>
References: <20190326154338.20594-1-cai@lca.pw>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.03.26-54.240.9.99
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000064, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 26 Mar 2019, Qian Cai wrote:

> +	if (!object) {
> +		/*
> +		 * The tracked memory was allocated successful, if the kmemleak
> +		 * object failed to allocate for some reasons, it ends up with
> +		 * the whole kmemleak disabled, so let it success at all cost.

"let it succeed at all costs"

> +		 */
> +		gfp = (in_atomic() || irqs_disabled()) ? GFP_ATOMIC :
> +		       gfp_kmemleak_mask(gfp) | __GFP_DIRECT_RECLAIM;
> +		object = kmem_cache_alloc(object_cache, gfp);
> +	}
> +
>  	if (!object) {

If the alloc must succeed then this check is no longer necessary.

