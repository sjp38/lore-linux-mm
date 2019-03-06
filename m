Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5A8A7C43381
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 19:20:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 29A2220661
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 19:20:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 29A2220661
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=davemloft.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C5FAF8E0003; Wed,  6 Mar 2019 14:20:29 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C360A8E0002; Wed,  6 Mar 2019 14:20:29 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B4C4E8E0003; Wed,  6 Mar 2019 14:20:29 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 616DC8E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 14:20:29 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id e14so7480896wrt.12
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 11:20:29 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date
         :message-id:to:cc:subject:from:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=XR59J7wGl3COw01HQfRSC8hpW+mOwyiiLHLXKBH0SDg=;
        b=G9lsjRmSOEtFIpSOnY8N390ieubZESKBbpCv9+9FDAtz3FM3fRwQ77wn8+qetE/oca
         XBe/RUSDXRQPlNfCpl78taPpTu2W4Yc0QncYrjh/hZ5++jKvFV4ldIE9LSVM4VK04R9A
         7MeHZwcMYMBzNFPfWQIHsy2N9d8QTsyBMfPEjXVsDFFbyz+aZ9VZJQxmEiNERfbdunbh
         ujaOTHKtChRgYxcF6G+QOytlh5Kjlu7xA9+ct7tSCIghdZxiljVZur1UYLdZQVsdFda6
         nnQwYmIFjKQ88FP6X2h+ga/Gt2pMLCIo2/8Ny4oZyQna6JH1pcgBF0XHhzSGn1S1s5Ko
         QTww==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
X-Gm-Message-State: APjAAAXGK7sXuhELQ7rpI79kMAnXeEFyNU1htbedm/IroVU5KthE4I33
	W766Mp9yk8Lqy5a67EKgrSB2rFzM922O4chpNzEO1Kmx04eam72cNHb4pSR+gnoP/SbOU/txyYR
	2DCVzFLvIgDssUyEn4TK1letsW+3RfTXFUqxzlCvx6TTG8oM5Aue6VtBUL8eTqgQ=
X-Received: by 2002:adf:dd43:: with SMTP id u3mr3843241wrm.259.1551900028973;
        Wed, 06 Mar 2019 11:20:28 -0800 (PST)
X-Google-Smtp-Source: APXvYqxLHdPUTKnNHd36kaJpw2qzXWgpFmvf7XFREqHGWRgJ8l+sLgmW4eIeFWUmnchqWEZntKri
X-Received: by 2002:adf:dd43:: with SMTP id u3mr3843213wrm.259.1551900028140;
        Wed, 06 Mar 2019 11:20:28 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551900028; cv=none;
        d=google.com; s=arc-20160816;
        b=MowaW5mCE+lPiVdCJQodjPkiULfQa0B+yeB14EKh7N/nJGVkpplx/UoWIpcWVbS2xC
         nOs/khG5//3iXWiYDlyBs67XLOutsRNEH2Huh9q26MgnYPpa7AENewCaQLS6nP5DE3Tx
         yeXchTQ5YpgEXcTP50jjPcV0PO3hq91FWucC2MJWJaYuyx1Ahr1y4Lux4Fzs0T54mhfg
         elOGdQ/XUR9VjIsctViQ5mQLV6YY6Fdyefa4StOWhgSY0iPeWxECx+nqbyUwQ1T1ApXI
         LmN5rUiUdhIi16uf45Z3JRyQ7t2oFK5h3KdUQDZCYd8UE2UTqihj40Ucy9QY01LpcP3q
         b6lQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:from
         :subject:cc:to:message-id:date;
        bh=XR59J7wGl3COw01HQfRSC8hpW+mOwyiiLHLXKBH0SDg=;
        b=OcpluD+TZHzWeK0vpvZ4ZgQPKJiDmaDKRWYeORotr9sC7oOasopjf+PoU3b5BFLQ31
         iDMjVSemD00hH3wIgIOE4qdKvpjk0TovgtpG/BgUyTl2YmzwndUoAiUIqNiNIPDSkTGk
         bepo/kLqaUR+OR4VzVHkvjIOKyj3Go/N8KuZs6CyShjAt2VsPT0Lg7rmt13t6Wm49TIC
         YTL2LfKSsOxpOeM5nOQ5wvGdRHQ8zyUNRTTTj+K0IydFpI7GnRa02qMsVPs40hzoB4k1
         s9KeqL177j5AKpU/vbAgv84OYq2N2klqXRHxCKxQdxaA2XP8983fGI9z2da3n4Iz/5Rw
         Eigw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2620:137:e000::1:9])
        by mx.google.com with ESMTPS id r8si1483531wmc.159.2019.03.06.11.20.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Mar 2019 11:20:27 -0800 (PST)
Received-SPF: neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) client-ip=2620:137:e000::1:9;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
Received: from localhost (unknown [IPv6:2601:601:9f80:35cd::d71])
	(using TLSv1 with cipher AES256-SHA (256/256 bits))
	(Client did not present a certificate)
	(Authenticated sender: davem-davemloft)
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 029451454DBAD;
	Wed,  6 Mar 2019 11:20:23 -0800 (PST)
Date: Wed, 06 Mar 2019 11:20:23 -0800 (PST)
Message-Id: <20190306.112023.204648705168304981.davem@davemloft.net>
To: alex@ghiti.fr
Cc: vbabka@suse.cz, catalin.marinas@arm.com, will.deacon@arm.com,
 benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au,
 schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
 ysato@users.sourceforge.jp, dalias@libc.org, tglx@linutronix.de,
 mingo@redhat.com, bp@alien8.de, hpa@zytor.com, x86@kernel.org,
 dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org,
 mike.kravetz@oracle.com, linux-arm-kernel@lists.infradead.org,
 linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
 linux-s390@vger.kernel.org, linux-sh@vger.kernel.org,
 sparclinux@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH v5 4/4] hugetlb: allow to free gigantic pages
 regardless of the configuration
From: David Miller <davem@davemloft.net>
In-Reply-To: <20190306190005.7036-5-alex@ghiti.fr>
References: <20190306190005.7036-1-alex@ghiti.fr>
	<20190306190005.7036-5-alex@ghiti.fr>
X-Mailer: Mew version 6.8 on Emacs 26.1
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.5.12 (shards.monkeyblade.net [149.20.54.216]); Wed, 06 Mar 2019 11:20:24 -0800 (PST)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Alexandre Ghiti <alex@ghiti.fr>
Date: Wed,  6 Mar 2019 14:00:05 -0500

> On systems without CONTIG_ALLOC activated but that support gigantic pages,
> boottime reserved gigantic pages can not be freed at all. This patch
> simply enables the possibility to hand back those pages to memory
> allocator.
> 
> Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>

For sparc:

Acked-by: David S. Miller <davem@davemloft.net>

