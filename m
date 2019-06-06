Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 527EBC04AB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 06:20:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 178502083D
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 06:20:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 178502083D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BA7736B026D; Thu,  6 Jun 2019 02:20:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B7E6B6B026F; Thu,  6 Jun 2019 02:20:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A46E86B0270; Thu,  6 Jun 2019 02:20:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6FD366B026D
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 02:20:48 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id u17so119745wmd.6
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 23:20:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=8gBGMllioW85+iMPaDMrXv4D/gv+I70GRpfge5BJ/no=;
        b=s026fkSxPiiQOx3YN6jk03ipKhLMTdicCyJaOQeScnp5TsT26vGjhOIaLbzDrBIKJh
         KiApIIFKdqyosrpu2DO0ut5zEeguw3LbtB+OhyRbYwzmjJGSwICz3rYlOLROV8bzxOJt
         Gowwu4yWBN68pivBW6ivJChWRF5wGSMgltEU4duwTCkitaQcYeNKyXdieNOWkDNTVqjb
         ITG1zqp1Su0HrVHq/l9JERCv5kR9SCn/ssGvsN+j1qchfDFvUEQLseXhieL7s20HmYkN
         6KNFCgydGKi99VNsc9fk4bkEuMGkA5wWc5/GSuv7/eQ6z0WZgXJCA62cvRhU+PehfV0A
         Q7uA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAVjLCyNgbPCoRKSpUuLCW2NyoOq+ajCVPae0dNjVhxBVwmG2s2E
	FUTqx14LVvc1LIxJ+QRbudt4FAxCnTdVamvwoKE1ZuSaQ0G4J3MS+qVx5GC2loLLSQCAh8uvpo3
	eyL9utpItErU/5lvUgiWyJCDs1Bc/UZbifcM6X0NFzdWdGirWkc1OBPx9RKCV9zlIFw==
X-Received: by 2002:a1c:c2d5:: with SMTP id s204mr25544997wmf.174.1559802048012;
        Wed, 05 Jun 2019 23:20:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwYR01DwcNQq/TNZQb3CmYjvQbgK/cWyVlh1VlMRqM2kn90Gd/U1auWZGRroCfeRZLzpyp3
X-Received: by 2002:a1c:c2d5:: with SMTP id s204mr25544961wmf.174.1559802047365;
        Wed, 05 Jun 2019 23:20:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559802047; cv=none;
        d=google.com; s=arc-20160816;
        b=D/Arn2I8hfmgATiLEmr0i8buV+liUkac9xjYCohoTvb8oZKgbCBxk9TzcwHEvAR/Wk
         vUT4yjY7KLuOR+CqX5PX706YZyYDIZVt+72lVT8s6R2c9wYPMj7v08NDE884kdLFwkEP
         hY8qBlD3HCghF3DevsUShDgt6TYdfYJ7FFNXpaKM6WH7Z0M/TG/zrYvEtr9Q54elYTPM
         TpCmHQgYaGibhWGBvF+OeI/48jljmmKZhQRDGFkMidFZMsg9ZEeJQNQK6EsBWP9leDnF
         oMpY8/SyGbHuUGKAGUIH9vresxymtxSpZ6PggdIv/967/ZYD0gvsNXaYpe1Z1bMRK6lV
         bUjg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=8gBGMllioW85+iMPaDMrXv4D/gv+I70GRpfge5BJ/no=;
        b=OTv91Ae/VHa7xDrHj1LnsaRKxYJgNfM+TB3IZ8okvccfB2irt5wz6N4ULhexHvR0UH
         +JOsG61I67s91ZBTKHSUjmgWwVfbiQifwzX99B5apLFwq1Qbwu/t7baR00NNLIVoCpOd
         ekjv6iQhs+kS/7iSNGHqfk3bUpe442Yi7bVQ2EkgUQidgA9rGKvwW0Vt+09JsbhgO70p
         bxwdCS04LhcFv/UxNNs85NVY8atEYh3VynLQ5Qwjq9NRkLwyfYFA/eJdgeOoY/ar84g1
         CcahcYqcuOOSnqkNVbqelBzs2xTbtjVGesRPJgbJsUkXvcRkscwkk+XJEZfhjx//TOgY
         O+2w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id l6si612990wmc.104.2019.06.05.23.20.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jun 2019 23:20:47 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id 55AF468B05; Thu,  6 Jun 2019 08:20:19 +0200 (CEST)
Date: Thu, 6 Jun 2019 08:20:18 +0200
From: Christoph Hellwig <hch@lst.de>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Christoph Hellwig <hch@lst.de>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Paul Burton <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Rich Felker <dalias@libc.org>,
	"David S. Miller" <davem@davemloft.net>,
	Nicholas Piggin <npiggin@gmail.com>,
	Khalid Aziz <khalid.aziz@oracle.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>, linux-mips@vger.kernel.org,
	linux-sh@vger.kernel.org, sparclinux@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 12/16] mm: consolidate the get_user_pages*
 implementations
Message-ID: <20190606062018.GA26745@lst.de>
References: <20190601074959.14036-1-hch@lst.de> <20190601074959.14036-13-hch@lst.de> <b0b73eae-6d79-b621-ce4e-997ccfbf4446@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b0b73eae-6d79-b621-ce4e-997ccfbf4446@nvidia.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 05, 2019 at 11:01:17PM -0700, John Hubbard wrote:
> I started reviewing this one patch, and it's kind of messy figuring out 
> if the code motion preserves everything because of
> all the consolidation from other places, plus having to move things in
> and out of the ifdef blocks.  So I figured I'd check and see if this is
> going to make it past RFC status soon, and if it's going before or after
> Ira's recent RFC ("RDMA/FS DAX truncate proposal").

I don't like the huge moves either, but I can't really think of any
better way to do it.  Proposals welcome, though.

