Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D52EBC43381
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 19:04:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A5DBD20657
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 19:04:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A5DBD20657
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=davemloft.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4A4A88E0009; Wed,  6 Mar 2019 14:04:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 42B658E0002; Wed,  6 Mar 2019 14:04:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2F59E8E0009; Wed,  6 Mar 2019 14:04:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id CD25E8E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 14:04:40 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id f4so7449182wrj.11
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 11:04:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date
         :message-id:to:cc:subject:from:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=goJRMkWz5s/p2RktxLYC0dw0+BSpl3HswqL1UjL8SWc=;
        b=rVFaod+TcXJV/WolFWfSgzmsJQk6gCt0hLJWuxAGQwnAGRkTx2sxebx+hm1507nEIq
         2YynB5bAD7bSTMUAGswLaIGHXySFvuQwXhFuhq5tfmq232Gd/o4AOU8G8mYtO1W1OEdD
         QGXgQIKTxHHI0MAgOZ4bGyjv3yrOKZYXl7Oye1iwhdrfQy/u/39MaSsSVQKvDlj6ug8O
         wL4IFiRMnxcygaYvuUikj7wckXoq+jyK86hqhxm/ZgJoNtz2fOm/TD7ek9eWe4ga1c+C
         o/FaDa0WNGVVgKfeNVd3nZYTg/S3DCI1QI4In4y+e16+8S6ZA7bYXxxJd5BkrstIkhM9
         s6YQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
X-Gm-Message-State: APjAAAXtWhexWuZlaLaDV2zIiibtAYvHhRmyBlX+clrRjgTlee86NWqp
	nwH+fT81Gorca8CaFB+X0zM/USmbpSUq3/9H/ShMvxyrVBpKqJlYJYCL8FddlamDsc5xz2IPh9j
	qjWuvXkBYeIOQIlN3Fcy2RP2quIdj6T4Oc7quiuvuzG8rbhqVD1NFHGzvzALbQQY=
X-Received: by 2002:adf:f102:: with SMTP id r2mr4058273wro.288.1551899080395;
        Wed, 06 Mar 2019 11:04:40 -0800 (PST)
X-Google-Smtp-Source: APXvYqwlbWPhU1DzcAvYCr4DjlA2X9Dmqfe1I74gfdpGpkSMU16j9Xpx5iqDqGHLMPDHy3M9Am+/
X-Received: by 2002:adf:f102:: with SMTP id r2mr4058251wro.288.1551899079717;
        Wed, 06 Mar 2019 11:04:39 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551899079; cv=none;
        d=google.com; s=arc-20160816;
        b=xmGqE3EGwkfFlw4+ccOrK19xWknoGrd56T1mtIfqltIS94qBmCioT9twkEeeT6s1H7
         +ux4e/WxpM+cGZ/lApFUBzwdZ9NNnxSgPKIcNqXmxG0L0OR/w5uIvnldhEKIyy4puczM
         3+AAKr029Pt6qlF+FIoDbcOYf6sozbOScK3QSEH74vEuhBkIUQLHAB7WR8i3CCbBkGUS
         wKwT5+EBUXuJnflZ4A6Y6K9AwCE4qEDJB8rsLMt+9eDixyOYQqFc/34pmmA/ligLWsQg
         4LzqalSlsBUNOlKtUMY2CSm8kOoi21cF3BT6lcT/Ol1AgLJUCVjEnNlDOeW3uWedIVhh
         ykiw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:from
         :subject:cc:to:message-id:date;
        bh=goJRMkWz5s/p2RktxLYC0dw0+BSpl3HswqL1UjL8SWc=;
        b=RwzGCFXennKLY5vMOkujn/nH4AiljZkBd6VSLS9VyFBqDDWF43ide4W8bzCGc4Kg0C
         LeBtte/rIQY5g1H24mGRNgf9j9sqkvnUnOAeHw8MhMUTvV6lQaCPlvq1pWIND+Ow0sBj
         o32XEkflWL+cltdyH7eIwiUQff2hNiIPLNL8RpUQiNHYnV6jWwXGMgx0wVD6jcuqamYL
         jM2qqUMCGbsXaN5gCuac3g0nY3j123CvKKCDZXNeB4gNkm+0vflWUXwYYlKlS0xKa31t
         qzF03jvUvdglz/GVQTMuByNtbTawh6Us8OVFSahquI2CQoBa3wD2ULTbXXqNCKff1iGi
         W+8Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2620:137:e000::1:9])
        by mx.google.com with ESMTPS id q17si1491523wrj.420.2019.03.06.11.04.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Mar 2019 11:04:39 -0800 (PST)
Received-SPF: neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) client-ip=2620:137:e000::1:9;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
Received: from localhost (unknown [IPv6:2601:601:9f80:35cd::d71])
	(using TLSv1 with cipher AES256-SHA (256/256 bits))
	(Client did not present a certificate)
	(Authenticated sender: davem-davemloft)
	by shards.monkeyblade.net (Postfix) with ESMTPSA id A91A1145183B2;
	Wed,  6 Mar 2019 11:04:36 -0800 (PST)
Date: Wed, 06 Mar 2019 11:04:36 -0800 (PST)
Message-Id: <20190306.110436.1714716608828903522.davem@davemloft.net>
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
Subject: Re: [PATCH v5 2/4] sparc: Advertise gigantic page support
From: David Miller <davem@davemloft.net>
In-Reply-To: <20190306190005.7036-3-alex@ghiti.fr>
References: <20190306190005.7036-1-alex@ghiti.fr>
	<20190306190005.7036-3-alex@ghiti.fr>
X-Mailer: Mew version 6.8 on Emacs 26.1
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.5.12 (shards.monkeyblade.net [149.20.54.216]); Wed, 06 Mar 2019 11:04:37 -0800 (PST)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Alexandre Ghiti <alex@ghiti.fr>
Date: Wed,  6 Mar 2019 14:00:03 -0500

> sparc actually supports gigantic pages and selecting
> ARCH_HAS_GIGANTIC_PAGE allows it to allocate and free
> gigantic pages at runtime.
> 
> sparc allows configuration such as huge pages of 16GB,
> pages of 8KB and MAX_ORDER = 13 (default):
> HPAGE_SHIFT (34) - PAGE_SHIFT (13) = 21 >= MAX_ORDER (13)
> 
> Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>

Much better.

Acked-by: David S. Miller <davem@davemloft.net>

