Return-Path: <SRS0=d6aY=VB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4ED73C0651F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Jul 2019 21:14:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 008F4218A0
	for <linux-mm@archiver.kernel.org>; Thu,  4 Jul 2019 21:14:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="L+QKnk1Q"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 008F4218A0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6B9396B0003; Thu,  4 Jul 2019 17:14:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 66A128E0003; Thu,  4 Jul 2019 17:14:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 57FDE8E0001; Thu,  4 Jul 2019 17:14:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 238836B0003
	for <linux-mm@kvack.org>; Thu,  4 Jul 2019 17:14:01 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id a13so4275990pgw.19
        for <linux-mm@kvack.org>; Thu, 04 Jul 2019 14:14:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=4S1VJ7BwX7NPp++KF73HWpEYSs073WFspQ12mTgq72I=;
        b=Qgqy6ZAwOYgYtYq7Knu+2IJW8MyifqSimbQzEaZyIu8VHyXLfRhzu9+BiehueZ/xjQ
         obK1CaLd/S7gDOYuFVp6RRPqsH02GQzgs4OxoTAmoknngWUWjnHohPJIRzZdRASLv+s8
         cDojlEoSCsHWDtqNt3eKLDdxlUn6OfXV77ed9gz34RpCjSUnb0erXz8ZY2cj8UkBYEVc
         FAt2Wq+H92Rv+8UKXv1GIwshhEfNC1pRVCdCjFsqC+3PLa5zOvbKYsXLiLyRLT4541oT
         ATdkBIp7641Ju63VivSpVrQyrOvs/8NEaq+Tsb9W0g18Xx2OQFvXimnjxdjA2k3eftDW
         gHww==
X-Gm-Message-State: APjAAAXvwzVZfcMnwesXQfusmaWnQPBfZwseiQdDT67BSPgJtqzmzMbV
	E3MthIlt9KgGqChC60Yh6uh1gmGk1zmwKNOrF+jUVinJcESoW1GRKUHjKoL8HOHwPJyB3mn1q+J
	9/mZufAmJugeJvOWy1QAkDk2olPFD08A/mNL+eBoxq1CHi55lJeec3uDqjvKfo93GTw==
X-Received: by 2002:a17:90a:258b:: with SMTP id k11mr66326pje.110.1562274840836;
        Thu, 04 Jul 2019 14:14:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqye1IWD54T/aFQ6CfjeatX2MpQuwB3Mv9vuR7DntmCfgUN5aPEchT+cT8It5djM4tbP10gD
X-Received: by 2002:a17:90a:258b:: with SMTP id k11mr66290pje.110.1562274840095;
        Thu, 04 Jul 2019 14:14:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562274840; cv=none;
        d=google.com; s=arc-20160816;
        b=BtcJ7Lfh1njOpglqcqaC0wx4dDplLy5s0vikTRRvBIyZ3UmxjwVVLzyKtYOCAKk8NM
         hEASOwliQBUfnBGm7Wg7t9xHRvs/LeraNrA9gN++aJkZhZKsvTdRYtF8MuJEmXb1G8G9
         VXjxYYgA9gXu9ktolulFwOXXnpPOhOEO6sHZ4hbF6/S/jX6dUKHJP1wyQOdnZrg5zJba
         Z1dQVsiflM+IFTJRyKXx8kYnFLc43uEU8PJu7ner7vl2M/rLMWuDf9EMuO13vfU+B98v
         GdX09XtJoYVaKJBA1VqHDKtg01nDpiy1+fHIc/Yl1dky3+i6h+2sdH9Y2FzHrTWu4mll
         VgXg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=4S1VJ7BwX7NPp++KF73HWpEYSs073WFspQ12mTgq72I=;
        b=DT9M08N2tpYVGQkBL5D51/c6Rwvuv7ySrues7sOYl56OiQpXFDm+hSlJg7pvSr7kAU
         xDqeH4Uocqt92Ej9mNFuD5lEsYZFQ6NQCbOwdw+G7s9YHkJmVV/tLktqejeNaoeIYUKU
         kIOnGcboCx+PEp8hpbKuEjCsq0xZC7Ic5S/TJxWA6UJ/iiNKbkirb3BhHFhNVRcJj4vx
         FdMmAbN5MJeu/INLBJM4XWNC5MWhyH1E67Nh28NFqzccGtNPBR0h4jEeEi9oyHJ4QKGc
         HfBvkRxE6r+ZZdd/s+NdNlqzgo4gzzyNdlR/5ns3t9CSaa7e3JkAyh+oWZ9zLOLvHlPy
         33MA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=L+QKnk1Q;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 63si6366400pfg.192.2019.07.04.14.13.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Jul 2019 14:14:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=L+QKnk1Q;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 11C3021850;
	Thu,  4 Jul 2019 21:13:59 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1562274839;
	bh=L5uTJJm8cS0jNeSEyq9UQDrpRWA/RzoGfVSTvhzwtI0=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=L+QKnk1QjgZhVbE+BLtQhirvztvvdNVrrXLB8pJs5cNBFXmtAcyrr2FU/Gr6TYhFG
	 a4RrGuNX9zgnsXHc3yAQk9TvTV7v0/u6KWK1iH3Hr8SvUC+EhKoU6ibelBN/fTzBCf
	 3Yyp+elIXhTbmdvHshxgTH40BD/iCrymubuF9R5g=
Date: Thu, 4 Jul 2019 14:13:58 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Robin Murphy <robin.murphy@arm.com>
Cc: Jason Gunthorpe <jgg@mellanox.com>, Christoph Hellwig
 <hch@infradead.org>, Mark Rutland <mark.rutland@arm.com>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>, "will.deacon@arm.com"
 <will.deacon@arm.com>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>,
 "anshuman.khandual@arm.com" <anshuman.khandual@arm.com>,
 "linux-arm-kernel@lists.infradead.org"
 <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org"
 <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Dan
 Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH v3 0/4] Devmap cleanups + arm64 support
Message-Id: <20190704141358.495791a385f7dd762cb749c2@linux-foundation.org>
In-Reply-To: <de2286d9-6f5c-a79c-dcee-de4225aca58a@arm.com>
References: <cover.1558547956.git.robin.murphy@arm.com>
	<20190626073533.GA24199@infradead.org>
	<20190626123139.GB20635@lakrids.cambridge.arm.com>
	<20190626153829.GA22138@infradead.org>
	<20190626154532.GA3088@mellanox.com>
	<20190626203551.4612e12be27be3458801703b@linux-foundation.org>
	<20190704115324.c9780d01ef6938ab41403bf9@linux-foundation.org>
	<20190704195934.GA23542@mellanox.com>
	<de2286d9-6f5c-a79c-dcee-de4225aca58a@arm.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 4 Jul 2019 21:54:36 +0100 Robin Murphy <robin.murphy@arm.com> wrote:

> >> mm-clean-up-is_device__page-definitions.patch
> >> mm-introduce-arch_has_pte_devmap.patch
> >> arm64-mm-implement-pte_devmap-support.patch
> >> arm64-mm-implement-pte_devmap-support-fix.patch
> > 
> > This one we discussed, and I thought we agreed would go to your 'stage
> > after linux-next' flow (see above). I think the conflict was minor
> > here.
> 
> I can rebase and resend tomorrow if there's an agreement on what exactly 
> to base it on - I'd really like to get this ticked off for 5.3 if at all 
> possible.

I took another look.  Yes, it looks like the repairs were simple.

Let me now try to compile all this...

