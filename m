Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D26EFC433FF
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 08:58:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AED66218A6
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 08:58:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AED66218A6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4457D6B0269; Thu, 15 Aug 2019 04:58:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3F55D6B026A; Thu, 15 Aug 2019 04:58:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2E3E06B026B; Thu, 15 Aug 2019 04:58:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0248.hostedemail.com [216.40.44.248])
	by kanga.kvack.org (Postfix) with ESMTP id 073F26B0269
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 04:58:23 -0400 (EDT)
Received: from smtpin16.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 99AEF40F4
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 08:58:23 +0000 (UTC)
X-FDA: 75824060886.16.birds64_492528564b222
X-HE-Tag: birds64_492528564b222
X-Filterd-Recvd-Size: 1746
Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by imf42.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 08:58:22 +0000 (UTC)
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 3445528;
	Thu, 15 Aug 2019 01:58:21 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 800573F706;
	Thu, 15 Aug 2019 01:58:20 -0700 (PDT)
Date: Thu, 15 Aug 2019 09:58:18 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Qian Cai <cai@lca.pw>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH -next] mm/kmemleak: increase the max mem pool to 1M
Message-ID: <20190815085817.GA9352@arrakis.emea.arm.com>
References: <1565807572-26041-1-git-send-email-cai@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1565807572-26041-1-git-send-email-cai@lca.pw>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 14, 2019 at 02:32:52PM -0400, Qian Cai wrote:
> There are some machines with slow disk and fast CPUs. When they are
> under memory pressure, it could take a long time to swap before the OOM
> kicks in to free up some memory. As the results, it needs a large
> mem pool for kmemleak or suffering from higher chance of a kmemleak
> metadata allocation failure. 524288 proves to be the good number for all
> architectures here. Increase the upper bound to 1M to leave some room
> for the future.
> 
> Signed-off-by: Qian Cai <cai@lca.pw>

Acked-by: Catalin Marinas <catalin.marinas@arm.com>

