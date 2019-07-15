Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_2 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 232D0C76191
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 15:18:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D8BB32054F
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 15:18:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="FW93TT0u"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D8BB32054F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 723256B0269; Mon, 15 Jul 2019 11:18:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6ACED6B026A; Mon, 15 Jul 2019 11:18:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 54D5C6B026B; Mon, 15 Jul 2019 11:18:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2E98A6B0269
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 11:18:05 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id h198so13979020qke.1
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 08:18:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=cRpKFS+Fyt9LbiY0I1uGPCo3RsVwfYk0idM+vjumZjA=;
        b=ZkeILCu9yAN9XFjw6+8a9J/gfQiuHMFma0ti+/fRmJF/hsGaG4wKKQAlJTJaMLYbVP
         LRnKOfzWGA0Kw4Ys1iAqG2H8FdWJ5w4Pd0TolBd9D7djLsoq51NDWtoG5qFWIKGSz19Q
         /LA5LMY2mq8N2D1zYWBGyTsKljbhXGSp+ldqdH1bNtm4nKVH7ewP175TkEgo8BjYctJc
         4Qy/gXtcPxXYV4g/ZWhvKa3nIhmI8DxKdRi7O0gwegxj1Pb11eriWI/CQJljzumAs/FG
         1FvO3aK2pb7GOiy23szNNdJqF7pItkiEAq4/g01Id++PjE8NzPeRjEOq4NtYI2bXpkhT
         KQWQ==
X-Gm-Message-State: APjAAAWs+URANl4bpBl2elheXpiMWqamxlVonts3SImssQfcgCT7vg3y
	yDphOwlUrSCD6UQo+vVDpEudi7hbewbFQUT6c8D9n2sljdMBzn/36RVutsQlVmdykL+yFPGeYLi
	8w1aOMU0Yv1hgwv/SsNjJWVoCOev5H1w2u9h+2U5uwSTSYMvFLFraxjYcObrM+XIaAQ==
X-Received: by 2002:a0c:8774:: with SMTP id 49mr18824841qvi.223.1563203884914;
        Mon, 15 Jul 2019 08:18:04 -0700 (PDT)
X-Received: by 2002:a0c:8774:: with SMTP id 49mr18824797qvi.223.1563203884323;
        Mon, 15 Jul 2019 08:18:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563203884; cv=none;
        d=google.com; s=arc-20160816;
        b=ZGCjE69PvAUCnQxF7NkkZcj1n5p8KwbirWc4eMM0GJ0Jp0Dg9aGjuOEpn3jRv2IOce
         BLUziCQicOTEbF/dNVeUfF3DO0P4cvEYrHmcAE8AoprHpY+YRxmhBavuKDgnpprG9LB/
         E/Sl1ojVTruZpTazEMx1IhOE/dIay+ho1cMQ32PWKlvIlB7i7+lklxJxyqG8QqPcmlB3
         8GwDVLFLYCBXDp4NTozrozlRDdif3JxVIw1OcGzpUXgxMlNztOZ0yDj73xLTysj9jh0O
         93szsi6ewHcIWTCTaVKc0nTQ0udZR1QEyRPaXfLNO3tgOS2eIHJLy0vCqyBdBaoPAuoK
         jYDw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=cRpKFS+Fyt9LbiY0I1uGPCo3RsVwfYk0idM+vjumZjA=;
        b=tcOxjQPiiFwY8llTwVQGFWWLzzJQYd8llkggLVQ2a+e5CRVxziU2ZfJPuLRpxT+6uo
         DuyFh2D7lblFM3hG0wUio/YzNVe40uuaoQL1r+RuF6VKydIfraAFpThXKs5hWwacXADh
         9pcEGJRzDwQnBMvIJJobu7eAHempHJ52eIJpGLkDrpA6eqr3qMMsRO7lWGi6XLKdmq4k
         WX0t3wjijtcXd6sxefDuTTViznQgb5+B6FnXF2hQbhPt7bJZ5JscEtpuORb4DhMotYyR
         /KT+zWxRUXd9lOEWy/U0xGt7UQpoSH13ew0QycBNwENO5i8ri8oMkgPP7itGKxjehkkf
         9csA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=FW93TT0u;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a4sor23975973qtn.36.2019.07.15.08.18.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 15 Jul 2019 08:18:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=FW93TT0u;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=cRpKFS+Fyt9LbiY0I1uGPCo3RsVwfYk0idM+vjumZjA=;
        b=FW93TT0uUkqJYlM64Rb3ivtPki+Y5zRRrdRBX35zervukDmNb89nBvc7LW6gyAM5I8
         LF91waCKAMrkT7MHNDv4dyhXEAIzhtV2fiYleJDyh4/ZP59skJTCchgrsRKqQATMOR23
         T8iW+SuvnqRn5a9h8B+9qGsl9GQY7aOCRIo98ipoTGIXMlbWXJv4ezLJIgRcwuyYnDWn
         lkiCB1EHTipRT4X2X83R2Bnbkg9toh3hq4aSBNP7C1ndCR+mc1jtJ4nKx8O2adZJ5pck
         pQcTgmyx5vdb3xuz/L2adPEpGkvazvqJQqWKtlm1Fo994mHz4b3c7b66VF9hWs849x1U
         B8LQ==
X-Google-Smtp-Source: APXvYqx6aw9F3hMC/lqfvZiuDSagGEHvd4jwPaC9u4/DDmcJvnugFN8K3ynyJgUCEy2eCj6WksZC6g==
X-Received: by 2002:ac8:7651:: with SMTP id i17mr17268712qtr.245.1563203884002;
        Mon, 15 Jul 2019 08:18:04 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id d141sm7800449qke.3.2019.07.15.08.18.02
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jul 2019 08:18:03 -0700 (PDT)
Message-ID: <1563203882.4610.1.camel@lca.pw>
Subject: Re: [PATCH] mm: page_alloc: document kmemleak's non-blockable
 __GFP_NOFAIL case
From: Qian Cai <cai@lca.pw>
To: Catalin Marinas <catalin.marinas@gmail.com>, Michal Hocko
	 <mhocko@kernel.org>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, "dvyukov@google.com"
 <dvyukov@google.com>, "akpm@linux-foundation.org"
 <akpm@linux-foundation.org>,  "linux-mm@kvack.org" <linux-mm@kvack.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Date: Mon, 15 Jul 2019 11:18:02 -0400
In-Reply-To: <F89E7123-C21C-41AA-8084-1DB4C832D7BD@gmail.com>
References: <1562964544-59519-1-git-send-email-yang.shi@linux.alibaba.com>
	 <20190715131732.GX29483@dhcp22.suse.cz>
	 <F89E7123-C21C-41AA-8084-1DB4C832D7BD@gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2019-07-15 at 10:01 -0500, Catalin Marinas wrote:
> On 15 Jul 2019, at 08:17, Michal Hocko <mhocko@kernel.org> wrote:
> > On Sat 13-07-19 04:49:04, Yang Shi wrote:
> > > When running ltp's oom test with kmemleak enabled, the below warning was
> > > triggerred since kernel detects __GFP_NOFAIL & ~__GFP_DIRECT_RECLAIM is
> > > passed in:
> > 
> > kmemleak is broken and this is a long term issue. I thought that
> > Catalin had something to address this.
> 
> What needs to be done in the short term is revert commit
> d9570ee3bd1d4f20ce63485f5ef05663866fe6c0. Longer term the solution is to embed
> kmemleak metadata into the slab so that we don’t have the situation where the
> primary slab allocation success but the kmemleak metadata fails. 
> 
> I’m on holiday for one more week with just a phone to reply from but feel free
> to revert the above commit. I’ll follow up with a better solution. 

Well, the reverting will only make the situation worst for the kmemleak under
memory pressure. In the meantime, if someone wants to push for the mempool
solution with tunable pool sizes along with the reverting, that could be an
improvement.

https://lore.kernel.org/linux-mm/20190328145917.GC10283@arrakis.emea.arm.com/

