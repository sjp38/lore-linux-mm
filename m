Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 14F70C10F03
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 15:06:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CEF2A217F5
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 15:06:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CEF2A217F5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5ED896B0003; Thu, 28 Mar 2019 11:06:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 574DB6B0006; Thu, 28 Mar 2019 11:06:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 43F426B0007; Thu, 28 Mar 2019 11:06:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id E4E3C6B0003
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 11:06:02 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id n24so8198696edd.21
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 08:06:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=clAOVY6tXGadt4PEXrN03gcZLtloSLapvhRmwBMijqU=;
        b=JmvN1qL68a3VidDEduMQYvsmTXUNYQag3AaeUSIT76tCQbLBViFz7NQoEdpmbfgy7U
         /xJegn6f8UCzRYdID/UIoSkJnOHKPy/FyBxm5i6rpQJxJGW2OQ0gYwc34/nqyBAj6MgY
         ihg8BpTX3fBsUQiTwEmeVNMXk+QOPpmEp9IFUpJwT+2nuKml0Bj3GUjELzTYgsZfmUQi
         kRP4wKYxzUaHVX2h+tvg4K+Dp0GkvgWVsnHFmT6Edn4Hr37cQul9xXlkc68XFO+OiZ/t
         5p/8ZLRFk4rT1uUUgUADQCeWIEZelHNP+Bfty21ym0fTxjTcVkmNCm6VA2D8y0Dq7VSf
         uWrw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAW0sje/aPtiR3/88hZufN6rhRjRZ61OogZQDELQGU7z5Ja1WaT6
	BNThXZ4BGKiGHxgXWxzPpYIf6HCh60CQFThhA3TTOOFh0+/O6r3f9v4TjnGG3LkYq9utSl6JWwo
	JKQ+bFoP41Dwn11puicr6ijtdWmdiZnkAnIHyaAjXgRDsQF6kjcQaYf4dNZIwkQoTkw==
X-Received: by 2002:aa7:dd8a:: with SMTP id g10mr28274577edv.52.1553785562536;
        Thu, 28 Mar 2019 08:06:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwQy2lUiU315UUQWu2d3LdKMX6UogdQVy38nMmGGazcGLAbipW4X1Uc/XAbON3KSD2K02Yq
X-Received: by 2002:aa7:dd8a:: with SMTP id g10mr28274535edv.52.1553785561772;
        Thu, 28 Mar 2019 08:06:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553785561; cv=none;
        d=google.com; s=arc-20160816;
        b=PTao7NJQRBRkVqvH2Ie5QciTkFd+AWx6ad54o5wacL3rB3nxlNmExwNxI1Z2Zg4fko
         JxSIh/3MiUNM6qlqPpQlF0lBsCse5zki55iRzK3/wJ21MVXauY/h1YzPJopV0Dg+ZrP3
         MxgukWrHcnbuP5BW3KouldTVV9JjaciirLZR2gs0HsGatgbxg9+BxrAgGIqZonixaCZ4
         pKC0edxp5dGg4VSK+sSbjimgb836OTjiKJd8dJ0DkuVLcRawU0Sc620qo/97DNL0k7yl
         K18n0RX2q2kcVCufe+RXuI7g++kZRff9Wat1W7V8Eik7YMOkU1qMbOISiaOW7fmrUEIP
         jYPA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=clAOVY6tXGadt4PEXrN03gcZLtloSLapvhRmwBMijqU=;
        b=lOoHJlBNLLHPNf5JA77Y9y+R9BpH+wROANK37Z83iqC5vleZAn8tuTxtD9VtRPeYAm
         tteZCX+WSfGUQ9cW/LFF3B0CmiWElF+Do0co9mtdwZ7lPQk5WhbVZBngFZmWqQYNByXN
         lDyLekQ4XoZRpAMfGVZLe0YyGhMZG9Nnmv9Y0O0U1h+Tkkjz1xkA6ZQM0XtwldaJf/yH
         47fEKF4PuOTdgqT4UL9//0UEz5ysA+L7eAZwd4D0zUL/M0zmq31o3zGLewt1tRdvnkJs
         Kj4ABX/LMJ4QnZs9NOo9gk03L2G3sXcXPpraVQpFzb0SwueJwkXY/Fx5tFZG6//WOmMB
         MttQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id j19si980156edr.82.2019.03.28.08.06.01
        for <linux-mm@kvack.org>;
        Thu, 28 Mar 2019 08:06:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id BE66A15AB;
	Thu, 28 Mar 2019 08:06:00 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id C6F063F575;
	Thu, 28 Mar 2019 08:05:58 -0700 (PDT)
Date: Thu, 28 Mar 2019 15:05:56 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
To: Qian Cai <cai@lca.pw>
Cc: Michal Hocko <mhocko@kernel.org>, akpm@linux-foundation.org,
	cl@linux.com, willy@infradead.org, penberg@kernel.org,
	rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH v4] kmemleak: survive in a low-memory situation
Message-ID: <20190328150555.GD10283@arrakis.emea.arm.com>
References: <20190327005948.24263-1-cai@lca.pw>
 <20190327084432.GA11927@dhcp22.suse.cz>
 <20190327172955.GB17247@arrakis.emea.arm.com>
 <49f77efc-8375-8fc8-aa89-9814bfbfe5bc@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <49f77efc-8375-8fc8-aa89-9814bfbfe5bc@lca.pw>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 27, 2019 at 02:02:27PM -0400, Qian Cai wrote:
> On 3/27/19 1:29 PM, Catalin Marinas wrote:
> > From dc4194539f8191bb754901cea74c86e7960886f8 Mon Sep 17 00:00:00 2001
> > From: Catalin Marinas <catalin.marinas@arm.com>
> > Date: Wed, 27 Mar 2019 17:20:57 +0000
> > Subject: [PATCH] mm: kmemleak: Add an emergency allocation pool for kmemleak
> >  objects
> > 
> > This patch adds an emergency pool for struct kmemleak_object in case the
> > normal kmem_cache_alloc() fails under the gfp constraints passed by the
> > slab allocation caller. The patch also removes __GFP_NOFAIL which does
> > not play well with other gfp flags (introduced by commit d9570ee3bd1d,
> > "kmemleak: allow to coexist with fault injection").
> > 
> > Suggested-by: Michal Hocko <mhocko@kernel.org>
> > Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
> 
> It takes 2 runs of LTP oom01 tests to disable kmemleak.

What configuration are you using (number of CPUs, RAM)? I tried this on
an arm64 guest under kvm with 4 CPUs and 512MB of RAM, together with
fault injection on kmemleak_object cache and running oom01 several times
without any failures.

-- 
Catalin

