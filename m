Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E6915C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 16:06:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B131C20866
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 16:06:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B131C20866
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3F74A6B000D; Tue, 26 Mar 2019 12:06:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 37FF06B000E; Tue, 26 Mar 2019 12:06:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 249456B0010; Tue, 26 Mar 2019 12:06:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id BB5CB6B000D
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 12:06:24 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id i59so5479237edi.15
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 09:06:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=gC5njTJokzuYnLO6T1L2PGEt+a8ve6SLWhGK1aYGBbA=;
        b=C0XQejMqTm1QgAf45wXIFyhQlQNc1q5XSYX4H60+nDVQFzDI9dlP76f+WEjRzzuqXJ
         hvGwi+a9GGl6ZlxmoG4kUWYiucWVaWOkRoT7/XY8BWiATCxrZEXw1Vs+unlyNKdsuuMm
         jzToiLd8nh5H3XK3PFHLn31AzXf+gx6vNFqJJEP1WYZDmblI6LuVZSr1UuonFeD2Omd4
         Z6Ir1aSc8AOqZHUheakSg8/P/LZE/+N8PCENNi3lBA4CIH3VrTqf3OSpp6VvAjhiUGT2
         msvPflSxGOvS0Z7x094F5Ll0YCKn4q/ygIgTwPzgA8yrRNd71KH25N2UU0IFbEuTj3cx
         vWow==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAUW+BVUCnZLc2eD88C2h1V1YsNmkmG12ctX9RMGhc9Gylplx6fE
	+Q3U/GM/hXhkO1YXDFXyoJFtSjxP9pvEVSWNg08/3V0MYiJiCSWLh5Jlp8yTW8lWAsZK3aXGG4n
	Lut/zmYbsI0en+CU3pNjC0d9xgK1DFzsHgcyoE4Irs1R0BmYZgWGxE2HLvz4v7eTibQ==
X-Received: by 2002:a50:92b2:: with SMTP id k47mr19683085eda.148.1553616384299;
        Tue, 26 Mar 2019 09:06:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxocY5pdGo9WfXH8hU8266cNKiU0mb+tBAzhAyK9URzAW5AaK80T0IcVdrQAlzb0Rk4G4et
X-Received: by 2002:a50:92b2:: with SMTP id k47mr19683045eda.148.1553616383580;
        Tue, 26 Mar 2019 09:06:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553616383; cv=none;
        d=google.com; s=arc-20160816;
        b=cS6gljIx3p+aKkdm90Y6zK/R5sNsIidRCvqs9Z61BNyewiumO+9SYmg2fhddoGKJRb
         ncfC5GkdkLGDkhdegmJAO4Wg8PiR/vggeOOn1t3pGS29sm+/v/laisbxoPboiTSqk4et
         J/lg/jm5hcsqmgn/WQtJ5Rza1PyiTSfNFA1mzLDEtmQ8OP12sNRic0KEwd8CpggyqAl1
         nA2SHNCO7MXszWhviTj7B+AdBDwntE8W8Q3yaUN/YacMXBiApxDYjhJMVnDcCTWxRWA0
         9lqdKe+Q9J/kUujgm2ocXAxBqjCH6FT682c5FXoytUJ9mrJfmCVU3ubMatCCZyzRkvBr
         X4lA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=gC5njTJokzuYnLO6T1L2PGEt+a8ve6SLWhGK1aYGBbA=;
        b=I0KnfvEX7QPa3aanqTMue2mHalJaRP7PyKPogt8lNTJS8oMzxxNgVTUIoKHix+yVQ+
         JWqdJukUqwKM2+i0BZRbnLe9ncTrg/CiUaSWfrk4t1a06M7zJvdDTVukoT8pPBhT8d1e
         wV6sXY30qLzkGabTE5GxycC/oovs8NwszoziuKSR8LRzdtsZ0mB9ctmoYa2BWmTPX3Mq
         HWwOYwvjCDgYboi5c/CnhNQS3CM2cntixvL742HX+Eji+XyIvSUkoVa8ypw9Du+4Vu04
         B0LHDkmG9fwvvNmST83GNpx77xlpvClxX2dxJQnrRVh7vE8U8OUTIeUgC/9Tox+LgSUZ
         rdUw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 15si3665104eds.84.2019.03.26.09.06.23
        for <linux-mm@kvack.org>;
        Tue, 26 Mar 2019 09:06:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 876E51596;
	Tue, 26 Mar 2019 09:06:22 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id BA4B33F614;
	Tue, 26 Mar 2019 09:06:20 -0700 (PDT)
Date: Tue, 26 Mar 2019 16:06:18 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
To: Qian Cai <cai@lca.pw>
Cc: akpm@linux-foundation.org, mhocko@kernel.org, cl@linux.com,
	penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v3] kmemleaak: survive in a low-memory situation
Message-ID: <20190326160617.GG33308@arrakis.emea.arm.com>
References: <20190326154338.20594-1-cai@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190326154338.20594-1-cai@lca.pw>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 26, 2019 at 11:43:38AM -0400, Qian Cai wrote:
> Kmemleak could quickly fail to allocate an object structure and then
> disable itself in a low-memory situation. For example, running a mmap()
> workload triggering swapping and OOM. This is especially problematic for
> running things like LTP testsuite where one OOM test case would disable
> the whole kmemleak and render the rest of test cases without kmemleak
> watching for leaking.
> 
> Kmemleak allocation could fail even though the tracked memory is
> succeeded. Hence, it could still try to start a direct reclaim if it is
> not executed in an atomic context (spinlock, irq-handler etc), or a
> high-priority allocation in an atomic context as a last-ditch effort.
> Since kmemleak is a debug feature, it is unlikely to be used in
> production that memory resources is scarce where direct reclaim or
> high-priority atomic allocations should not be granted lightly.
> 
> Unless there is a brave soul to reimplement the kmemleak to embed it's
> metadata into the tracked memory itself in a foreseeable future, this
> provides a good balance between enabling kmemleak in a low-memory
> situation and not introducing too much hackiness into the existing
> code for now.

Embedding the metadata would help with the slab allocations (though not
with vmalloc) but it comes with its own potential issues. There are some
bits of kmemleak that rely on deferred freeing of metadata for RCU
traversal, so this wouldn't go well with embedding it.

I wonder whether we'd be better off to replace the metadata allocator
with gen_pool. This way we'd also get rid of early logging/replaying of
the memory allocations since we can populate the gen_pool early with a
static buffer.

-- 
Catalin

