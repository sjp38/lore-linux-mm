Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D7D8FC43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 14:20:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6800A206BA
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 14:20:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6800A206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E52C86B0003; Wed, 20 Mar 2019 10:20:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E34836B0006; Wed, 20 Mar 2019 10:20:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D3EBB6B0007; Wed, 20 Mar 2019 10:20:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7EF656B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 10:20:25 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id x13so976118edq.11
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 07:20:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=WLU6DfvoTVh//Q1t3fKPvXvzFiQAXH20EBL17Q2f+ZA=;
        b=SNpkIlZPy9q8xfdFO0meHKlvsSZZciDuKlwclsxITaConhyKWE7ED3GAUw7txFRfWr
         SpRn3CElxX8JbsWuCbXOLH6XjQCwzTSdiSnW1WT+wlE3fmu3Xm34dxr4xCNKgtdAEbC8
         thzmQAKViky/dKnMRGX1drgWDkZ4JWOp1DeRHtSo77xsihiXhkSl7hQ6A7B+qStNlJ5Z
         lnqz0HyFviBMjeJZFL+42IOq2nSGPUSMAyVBbiVLoPJo1VFepuMFr7v+3elzWlML4V0g
         k4CCsfamUrrpPe6Rl6RfqmqDNWTgWsfVPRv9UXctK4y6n1s2XGx6GUr6FEjBafdaOc7A
         zCTw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.15 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: APjAAAXRzyEkWXArI6ifkS4xyRsJ80to88lfbZF2u5TQ0r6Myu7sW00E
	cipK1eSn4XSLujB0da8TofSKHzuaoS01X62c9vNHEEIxZ5+W6scTYNo+FZTOMfpM402DDwB7rsz
	zVYkUvb7C5pnq0lzzX6tEd6GOrss6fzp5Ht8zXK6gTy/pW5Q0ab0zc7EHMfb7gc4+hg==
X-Received: by 2002:a50:9ea8:: with SMTP id a37mr20411295edf.147.1553091625080;
        Wed, 20 Mar 2019 07:20:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz3f8JswmrQh0Y+Zw+A8GWjboRUNWm0r+/91EE1stVxnlyEO+N6LItpiKxjxHv6vBuDjyqh
X-Received: by 2002:a50:9ea8:: with SMTP id a37mr20411229edf.147.1553091623922;
        Wed, 20 Mar 2019 07:20:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553091623; cv=none;
        d=google.com; s=arc-20160816;
        b=B1FrTA/iIina/TeFxndHBWlcMSHRFKd93HOCQaSqRqNMX1GN1JeO5ym2yw+VFk5u+N
         bKMM/XrPh+as65lFdSJ94nOgnQdhoow01FaoLUGlA3qQU3oQUhNZJ2gXkHDF0zBTpH2F
         LR2VlnlL9vF+kR7eRbsSx4C7UO7e/pGYVx2UqsiABB71AJE7KzlpWwfJCLGSa359aKUA
         u8YMc6eg+esaepaFHzwIEgcLSs8I2wHlrEn7vCs2OfZGTMRcWG27d1BSMrlvMahHRVen
         HAlUI3KUfVtRSHzjo+4Cy7UGNMdeU8I4V1gXiNQhJgzhC/DR2aywx8umsPufMhA9RccE
         nw3A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=WLU6DfvoTVh//Q1t3fKPvXvzFiQAXH20EBL17Q2f+ZA=;
        b=Ld1+ytAEZFtuRJEyrbCMXx1kev5QsvCv9dkM0CsX2vDqR5yQ295+Zkxt+FCe8TPCwq
         nrbuZ9eQeer7V+G/M/27rdp7WV9RVT3K1hxj3Mmw9AU5Cdu0XTxKld2qOU+7RanfrrZr
         KOYmRBraAC+oc3aBkHeBwWWkwkVgmeC4ZukqBQ56Jt4cevVJocuNOGYcTCD8eEHGPMVI
         uPK4itFZWOXWIAS15QVe3psza1s/acul/0ubAYj8Xr3rdDscGr8ZU3fCWtQ780i4g2OX
         m0IIjB0p9h2VmKmUgqpKNqQ4NHtn7U4FwmYh5AI4P9gg25dJ5VRxepNt/KWJYyF1gzPQ
         PVkQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.15 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id t39si912278edb.54.2019.03.20.07.20.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Mar 2019 07:20:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.15 as permitted sender) client-ip=46.22.139.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.15 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id 7A3C81C312A
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 14:20:23 +0000 (GMT)
Received: (qmail 1835 invoked from network); 20 Mar 2019 14:20:23 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[89.19.67.207])
  by 81.17.254.9 with ESMTPSA (DHE-RSA-AES256-SHA encrypted, authenticated); 20 Mar 2019 14:20:23 -0000
Date: Wed, 20 Mar 2019 14:20:21 +0000
From: Mel Gorman <mgorman@techsingularity.net>
To: Qian Cai <cai@lca.pw>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>,
	Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>, linux-mm@kvack.org,
	vbabka@suse.cz
Subject: Re: kernel BUG at include/linux/mm.h:1020!
Message-ID: <20190320142021.k4z6njs2kacdip3k@techsingularity.net>
References:<CABXGCsM-SgUCAKA3=WpL7oWZ0Xq8A1Wf-Eh6MO0seee+TviDWQ@mail.gmail.com>
 <20190315205826.fgbelqkyuuayevun@ca-dmjordan1.us.oracle.com>
 <20190317152204.GD3189@techsingularity.net>
 <1553022891.26196.7.camel@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To:<1553022891.26196.7.camel@lca.pw>
User-Agent: NeoMutt/20170912 (1.9.0)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 19, 2019 at 03:14:51PM -0400, Qian Cai wrote:
> On Sun, 2019-03-17 at 15:22 +0000, Mel Gorman wrote:
> > On Fri, Mar 15, 2019 at 04:58:27PM -0400, Daniel Jordan wrote:
> > > On Tue, Mar 12, 2019 at 10:55:27PM +0500, Mikhail Gavrilov wrote:
> > > > Hi folks.
> > > > I am observed kernel panic after updated to git commit 610cd4eadec4.
> > > > I am did not make git bisect because this crashes occurs spontaneously
> > > > and I not have exactly instruction how reproduce it.
> > > > 
> > > > Hope backtrace below could help understand how fix it:
> > > > 
> > > > page:ffffef46607ce000 is uninitialized and poisoned
> > > > raw: ffffffffffffffff ffffffffffffffff ffffffffffffffff ffffffffffffffff
> > > > raw: ffffffffffffffff ffffffffffffffff ffffffffffffffff ffffffffffffffff
> > > > page dumped because: VM_BUG_ON_PAGE(PagePoisoned(p))
> > > > ------------[ cut here ]------------
> > > > kernel BUG at include/linux/mm.h:1020!
> > > > invalid opcode: 0000 [#1] SMP NOPTI
> > > > CPU: 1 PID: 118 Comm: kswapd0 Tainted: G         C
> > > > 5.1.0-0.rc0.git4.1.fc31.x86_64 #1
> > > > Hardware name: System manufacturer System Product Name/ROG STRIX
> > > > X470-I GAMING, BIOS 1201 12/07/2018
> > > > RIP: 0010:__reset_isolation_pfn+0x244/0x2b0
> > > 
> > > This is new code, from e332f741a8dd1 ("mm, compaction: be selective about
> > > what
> > > pageblocks to clear skip hints"), so I added some folks.
> > > 
> > 
> > I'm travelling at the moment and only online intermittently but I think
> > it's worth noting that the check being tripped is during a call to
> > page_zone() that also happened before the patch was merged too. I don't
> > think it's a new check as such. I haven't been able to isolate a source
> > of corruption in the series yet and suspected in at least one case that
> > there is another source of corruption that is causing unrelated
> > subsystems to trip over.
> > 
> 
> So reverting this patch on the top of the mainline fixed the memory corruption
> for me or at least make it way much harder to reproduce.
> 
> dbe2d4e4f12e ("mm, compaction: round-robin the order while searching the free
> lists for a target")
> 

Ok, thanks for that. I'm just about to fly and didn't reexamine the
patch in detail. I'll review again and see if there are cases where
order goes negative which would lead to improper accesses when I get
back online properly. It's possible that next_search_order() is ending
up with negative values because of assumptions made about the value of
cc->order.

