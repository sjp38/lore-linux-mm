Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7B8DBC43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 19:08:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1EC8421B24
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 19:08:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="cEctZLfP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1EC8421B24
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 874AC8E0002; Thu, 14 Feb 2019 14:08:23 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 824178E0001; Thu, 14 Feb 2019 14:08:23 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6C4AB8E0002; Thu, 14 Feb 2019 14:08:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 260358E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 14:08:23 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id t72so5476161pfi.21
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 11:08:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Z/guOjnPcwW8qHKWLH6ei2fgh2Qlw1Lh/RZ/6h84/Co=;
        b=OFBYr8haRp6u7UeiGCRdeLi2I09BzNhkNdCjSa4N0eefGYEqOlUU1kMRTrxqVXpdu0
         SvFPkt4vdHk6rfeb23hUYeRMKzVu0MKeAMkNkLyxIhoHbmAqep9pQiwm9uSkfXDWDbUd
         xzwWi5u0IBh7x4Vq0GAnvRFvibkQuw85Eq4toDTBQW9CVWCh30DdE+v/jIJd3q4QAIcx
         1WRcYn2lCLPFP/en6uKq7ox1TTHWILDRRJzmA0HbRkHlf3xaTAaKq7WTSwhuWH+/QNcL
         z3Cg09zzoTrXRLR1ly2Qm/a/3gfwfBWAsftqL9EKBu1sJQAYPh83RkRQBfL99c+tOqLE
         g+gg==
X-Gm-Message-State: AHQUAuafwZNT/5l73/E4fEiM2n4RsmnA7/5ExdvonkfoWB0gmDJeplSq
	Wx38iy035DeCgjOrxBOUYdzkpiClK1g4boK2z+5nJAEc/U7DBcqoMxM8tN4neW++auaNcpGeWUW
	B7+3jH/2iNxrujbC3f05dc9VNEtZ+LkCV1TjuTvsHZ1nQFrC/lFp2ga3lMFq3hWFkkw==
X-Received: by 2002:a63:1143:: with SMTP id 3mr5169601pgr.447.1550171302747;
        Thu, 14 Feb 2019 11:08:22 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYbxo2cAUBYYUVePDaW6i5EBI1yeDgiTfWqb7t57cLFEHH6j5/OAxTAAsHmiQ5HXDiQoP6O
X-Received: by 2002:a63:1143:: with SMTP id 3mr5169531pgr.447.1550171301797;
        Thu, 14 Feb 2019 11:08:21 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550171301; cv=none;
        d=google.com; s=arc-20160816;
        b=lTe/L4UyxnEZ/L2zfs9g1uNi+EqAriQ3kXhYVz2xrqRHf8MCBIVbDRq6GqKfVT5Ny9
         J6aTSDT139r61Dtn1N3fcHzFQU8PeN8FI2vEiYpn6LE5OxXb+p49wCqMxZdp7MBf5qsC
         Dhun9qfwabGew7YMUP4k9UCkFIUe20bGaI6c2r1DBm6mb6jFgmcdwOQtqJweG2ZjNg2z
         JWR6WDxzPD3AVZJgaP3gw+kUKusfHJfg+eAj8FIXZLqytRypSdkKGUbQlMLtO7KDsZlx
         gzbp3KOLgcCkho1vITQ+fWnbIgn4sH81ATGm2BqatGaL5Rjliko2qL3LDHtmD8xNljsU
         WKAw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Z/guOjnPcwW8qHKWLH6ei2fgh2Qlw1Lh/RZ/6h84/Co=;
        b=NezLyNSjLESaySXHqpSHsgGYvBE/3JUH/73dunCvHis0ghvpnNF2dihTytFcPghIOJ
         G7dnYYvNewPzAKgIgN73u0D5jNdE88T19onwH3UYsqyICl/o6mc5tGEcSZMQq8Jawj0U
         AXRa9yc6Sg6VDQPojqGudcv+g9qa0V6O4wdM5PavWHIDJ3U2T/jJmDOeTbT/tUhD0jPp
         8VZ+IRxXst7bUSY0C4xQ0OaMM7G6G7G7nihHMILOAgPt0nqWGP+vpCyLRbMulTyYLh7r
         JJoO+CztQ/fDf2quwLAJiI9loFHQOIQUTX6mhN0VZSS/+o8Vf1zkR9YOq8LLpR6pFauj
         PeQA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=cEctZLfP;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d188si3055575pgc.97.2019.02.14.11.08.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 14 Feb 2019 11:08:21 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=cEctZLfP;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=Z/guOjnPcwW8qHKWLH6ei2fgh2Qlw1Lh/RZ/6h84/Co=; b=cEctZLfPAGyPtiErBt/B7+YbC
	FeY0fEvhO8Ygf80DDHtmxGTehgHHi0sskUBDjyZAG4N8ijgXeDUcY2/jW79FOvaQrJyoYLT0AYg0x
	yb4GtkElgIVSF2LyFauA27vzP1D8LHzPLHaNnLudneFG4X2cG1LyUcMR4ja1CdksGBKeEO8tsicQK
	iRMJW8pNONeP0aUmXyuGEbtCaNwUKfpRrBhkQDjQ29HOdkXHkZeIhwQRMsb6UgN5visI12myCUf/p
	QVjnV+bDarRTCC4lqWPcnD1kk1jKf+w8aj8gpZUJUrPKXh5W8WWyc3AuyNJVr7deMrBpqCQfYkCko
	ZNwcj2KFQ==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1guMMg-0003Hu-An; Thu, 14 Feb 2019 19:08:06 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id BD3D020268335; Thu, 14 Feb 2019 20:08:03 +0100 (CET)
Date: Thu, 14 Feb 2019 20:08:03 +0100
From: Peter Zijlstra <peterz@infradead.org>
To: Khalid Aziz <khalid.aziz@oracle.com>
Cc: juergh@gmail.com, jsteckli@amazon.de, tycho@tycho.ws,
	ak@linux.intel.com, torvalds@linux-foundation.org,
	liran.alon@oracle.com, keescook@google.com,
	akpm@linux-foundation.org, mhocko@suse.com, catalin.marinas@arm.com,
	will.deacon@arm.com, jmorris@namei.org, konrad.wilk@oracle.com,
	Juerg Haefliger <juerg.haefliger@canonical.com>,
	deepa.srinivasan@oracle.com, chris.hyser@oracle.com,
	tyhicks@canonical.com, dwmw@amazon.co.uk, andrew.cooper3@citrix.com,
	jcm@redhat.com, boris.ostrovsky@oracle.com,
	kanth.ghatraju@oracle.com, oao.m.martins@oracle.com,
	jmattson@google.com, pradeep.vincent@oracle.com,
	john.haxby@oracle.com, tglx@linutronix.de,
	kirill.shutemov@linux.intel.com, hch@lst.de,
	steven.sistare@oracle.com, labbott@redhat.com, luto@kernel.org,
	dave.hansen@intel.com, kernel-hardening@lists.openwall.com,
	linux-mm@kvack.org, x86@kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	Tycho Andersen <tycho@docker.com>,
	Marco Benatto <marco.antonio.780@gmail.com>
Subject: Re: [RFC PATCH v8 03/14] mm, x86: Add support for eXclusive Page
 Frame Ownership (XPFO)
Message-ID: <20190214190803.GQ32477@hirez.programming.kicks-ass.net>
References: <cover.1550088114.git.khalid.aziz@oracle.com>
 <8275de2a7e6b72d19b1cd2ec5d71a42c2c7dd6c5.1550088114.git.khalid.aziz@oracle.com>
 <20190214105631.GJ32494@hirez.programming.kicks-ass.net>
 <e157e274-1bdf-0987-bfe9-21c9301578ab@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e157e274-1bdf-0987-bfe9-21c9301578ab@oracle.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 14, 2019 at 10:13:54AM -0700, Khalid Aziz wrote:

> Patch 11 ("xpfo, mm: remove dependency on CONFIG_PAGE_EXTENSION") cleans
> all this up. If the original authors of these two patches, Juerg
> Haefliger and Julian Stecklina, are ok with it, I would like to combine
> the two patches in one.

Don't preserve broken patches because of different authorship or
whatever.

If you care you can say things like:

 Based-on-code-from:
 Co-developed-by:
 Originally-from:

or whatever other things there are. But individual patches should be
correct and complete.

