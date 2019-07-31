Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 54FC5C32753
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 09:54:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 25975206A3
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 09:54:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 25975206A3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 967DA8E0003; Wed, 31 Jul 2019 05:54:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 917F18E0001; Wed, 31 Jul 2019 05:54:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 806EB8E0003; Wed, 31 Jul 2019 05:54:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2FD758E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 05:54:02 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id w25so42011704edu.11
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 02:54:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=pRZTH1UnbJrAmszDTbdI2eG/7bKliGgGc1MjRGmZxig=;
        b=YS6o6ZMdAVHWwa1aqAOONG+oQcJBCgA2wOqEFy31usaVf1S7UXV7yusXtzfjUjmtrY
         BGsrOYAL/WCfie4DFTEUIilc+XCAzOvSoFNh+7ogZpVlBn4QxcFdoad++X2kjcduqZ8E
         zNr338PQoAGpT+Szq3jQcz6ahZiE+lEzpOJerfsJH3yrG7rs19Xbni/rgqqzniRC/ETa
         9yzX9oruXPGrelEMbY9rrpDncyPZGljrx5FUrf9FzE92+pyoZSvDsJzKuPLLFbL+P3gP
         IAYuLMWRBMgw9l4jq2IHLTKe0evxMa3Px0c1aoMN4Mhwc2aCgseae0Brr6yLZVs5iKzP
         zBug==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAX+SzIG94fA1gJ1RD6zm2u7e8kZaFTJMQf9lFaDZE4ErLdZLvlr
	6SjHdjSee36wh3LL9S7D4eoHwr2pQdj7eZ34rEtHlO6jzBCjPfaHW9LLPIpou2Pw49lO/t/BeJk
	CN666b/mZujNjL7GZEjdgqlzyFCfSrVRKLeHfUthE5xCZffmLf4F+Yc5HMLIO+tfgGw==
X-Received: by 2002:a17:906:7f16:: with SMTP id d22mr93729282ejr.17.1564566841750;
        Wed, 31 Jul 2019 02:54:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwFsIBfYA3Wal0N9O19wThCWELamlMciP83oeZ1Y+iGwgymxovSyUAwbSEq7YhjDqA+gwwF
X-Received: by 2002:a17:906:7f16:: with SMTP id d22mr93729246ejr.17.1564566840986;
        Wed, 31 Jul 2019 02:54:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564566840; cv=none;
        d=google.com; s=arc-20160816;
        b=CFKlsRkqx8S4yTOkcDL84hBq0F8cjADOEPPAemGTx61VosoQRvfpMgwkpVyxuSebnT
         tZXhWwvRrMaj4NX7Eh9taCpoBVCWTgOTG3J5x09TqApzMOv+OJliudBFIUeKRf2p2gnC
         SpOC9cprTrItSrl1V4H8V1S6g+6nyIs0LAhsE+ohjYE8jpcZY5TCxwB4peECy1AOJ8re
         RbIX86e+CXcXkQ9pZxvOcBIWw51oe260ngy/+0YUTQAg8bhQhExHeH3j/YA4NmIMr0hC
         CKArMGw5+QWXBaGoeGX13ISGI61uiN1BQmBU/5kRuOnAhGDS0YR2Ztj/cdfyvXicYIXW
         CdhQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=pRZTH1UnbJrAmszDTbdI2eG/7bKliGgGc1MjRGmZxig=;
        b=T7waUB9UgY8r9mvmPk4fAJcRDlOy7zzMw2AY4q0nzFA/yFY4cWl430TXj0sy1d8asu
         3YMVWSjzI6RxIDsq8wqR9cljDE7EgtJZla/UqBP6OTGBoc0NUM8sj9cgtsv0hXuniqtx
         sWbnvwmiOLfk0l1/k8ECCdN9PvqWYE6m+LKec+BfVCdVhUdCE9wLfX+SmGxNRa7nLQcU
         A4CO7/IJrwmzxRm0TcEpdxaRKm4++9mJmQ7rf/H2ZWSBgXT8OJ4+h8UQB/zMlemhZmIJ
         ECKF/LazRJjmF8D0bKVR9qzup0XreoU5+vUbLfZJ2m95Mn9jxRu+AYEsMW/CWjB39MDP
         aOAg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id r6si20605181eda.197.2019.07.31.02.54.00
        for <linux-mm@kvack.org>;
        Wed, 31 Jul 2019 02:54:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id D67D0337;
	Wed, 31 Jul 2019 02:53:59 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id E50EE3F71F;
	Wed, 31 Jul 2019 02:53:58 -0700 (PDT)
Date: Wed, 31 Jul 2019 10:53:56 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Qian Cai <cai@lca.pw>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>,
	Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v2] mm: kmemleak: Use mempool allocations for kmemleak
 objects
Message-ID: <20190731095355.GC63307@arrakis.emea.arm.com>
References: <20190727132334.9184-1-catalin.marinas@arm.com>
 <20190730125743.113e59a9c449847d7f6ae7c3@linux-foundation.org>
 <1564518157.11067.34.camel@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1564518157.11067.34.camel@lca.pw>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 30, 2019 at 04:22:37PM -0400, Qian Cai wrote:
> On Tue, 2019-07-30 at 12:57 -0700, Andrew Morton wrote:
> > On Sat, 27 Jul 2019 14:23:33 +0100 Catalin Marinas <catalin.marinas@arm.com>
> > > --- a/Documentation/admin-guide/kernel-parameters.txt
> > > +++ b/Documentation/admin-guide/kernel-parameters.txt
> > > @@ -2011,6 +2011,12 @@
> > >  			Built with CONFIG_DEBUG_KMEMLEAK_DEFAULT_OFF=y,
> > >  			the default is off.
> > >  
> > > +	kmemleak.mempool=
> > > +			[KNL] Boot-time tuning of the minimum kmemleak
> > > +			metadata pool size.
> > > +			Format: <int>
> > > +			Default: NR_CPUS * 4
> > > +
> 
> Catalin, BTW, it is right now unable to handle a large size. I tried to reserve
> 64M (kmemleak.mempool=67108864),
> 
> [    0.039254][    T0] WARNING: CPU: 0 PID: 0 at mm/page_alloc.c:4707 __alloc_pages_nodemask+0x3b8/0x1780
[...]
> [    0.039646][    T0] NIP [c000000000395038] __alloc_pages_nodemask+0x3b8/0x1780
> [    0.039693][    T0] LR [c0000000003d9320] kmalloc_large_node+0x100/0x1a0
> [    0.039727][    T0] Call Trace:
> [    0.039795][    T0] [c00000000170fc80] [c0000000003e5080] __kmalloc_node+0x520/0x890
> [    0.039816][    T0] [c00000000170fd20] [c0000000002e9544] mempool_init_node+0xb4/0x1e0
> [    0.039836][    T0] [c00000000170fd80] [c0000000002e975c] mempool_create_node+0xcc/0x150
> [    0.039857][    T0] [c00000000170fdf0] [c000000000b2a730] kmemleak_init+0x16c/0x54c
> [    0.039878][    T0] [c00000000170fef0] [c000000000ae460c] start_kernel+0x69c/0x7cc
> [    0.039908][    T0] [c00000000170ff90] [c00000000000a7d4] start_here_common+0x1c/0x434
[...]
> [    0.040100][    T0] kmemleak: Kernel memory leak detector disabled

It looks like the mempool cannot be created. 64M objects means a
kmalloc(512MB) for the pool array in mempool_init_node(), so that hits
the MAX_ORDER warning in __alloc_pages_nodemask().

Maybe the mempool tunable won't help much for your case if you need so
many objects. It's still worth having a mempool for kmemleak but we
could look into changing the refill logic while keeping the original
size constant (say 1024 objects).

> [   16.192449][    T1] BUG: Unable to handle kernel data access at 0xffffffffffffb2aa

This doesn't seem kmemleak related from the trace.

-- 
Catalin

