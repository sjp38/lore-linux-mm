Return-Path: <SRS0=hU9b=SV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D2BF9C282DA
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 11:14:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7AD99218EA
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 11:14:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7AD99218EA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1D1896B0007; Fri, 19 Apr 2019 07:14:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 159336B0008; Fri, 19 Apr 2019 07:14:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 020F06B000A; Fri, 19 Apr 2019 07:13:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id A5C2A6B0007
	for <linux-mm@kvack.org>; Fri, 19 Apr 2019 07:13:59 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id n25so2736857edd.5
        for <linux-mm@kvack.org>; Fri, 19 Apr 2019 04:13:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=V5LySrDNIuJfRn6aGIE9UpyfQnEuTeFHcaLHDpOcTzQ=;
        b=cIevqLR2BJRO+a9vaupXfF3CwlE8bAQP7yrIGveYYva4AmXeLco3/Y01cEh8XETGyU
         Tf8b7IhAQBH5UTS9KAEsuyYwOITnWW8+fQc//M+DwS+kq7hnoS0vb2B87pOKyP9BFMD1
         dYbuQEDFnxW7swjfzhFKd2sXwR1a7Mlv2MFd0IUgUum3U1QMUYLpYemd4fz1pOtj12k1
         cXs26gtWykbfnRThtGHJYsjFwn6ot4Z6QGIui0EhakHTD/0aY8s2V54oCRrUUAOE8rHo
         G2WEWYRVaczp0p26Dii+j0g2JktpDhHou1u4g6UL7pSfgkSlqAezxylCkSUjXZs0ytsc
         qL1g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.38 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: APjAAAW0VHDVxv7VLGibViPV4ckT3FnaWHqEN7/KkoFyBTnd+gV95bg8
	VC8sWDS5LN+UEDXCY3wySnKsHOClW6sB3tZyidQT6k8B0rmsElrrW1NxJXJep75hnyT2Rx8Io0C
	Qv6E2adFQMW4ZBvu8cgbofE79TUOU71/DLZu2py27DGTUXFgDve97iHTcm/dHfi2BRQ==
X-Received: by 2002:a17:906:3654:: with SMTP id r20mr1671568ejb.155.1555672439165;
        Fri, 19 Apr 2019 04:13:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyhPvJNJ+afbVzhAYWP2zRCC1dqZJkg0dA37vgBbN7t16ZrPOYWO8RaxoHzjBQSG8BJYDl4
X-Received: by 2002:a17:906:3654:: with SMTP id r20mr1671533ejb.155.1555672438331;
        Fri, 19 Apr 2019 04:13:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555672438; cv=none;
        d=google.com; s=arc-20160816;
        b=pOK6+bz8d/y98ZOCR0BGkky74PlMYoFSL4sJ8aT09+cuDzmjiza5DfffSd0ctmTWDM
         I9vhOkRnlX1gjAX9fq+FtkS6OsHkoXKpKIUf4HX8IzWMNerqVMyuOk7JsIHwLgxysO8T
         owcSUmdAL5o5N+vSejHaABkfdXEJRqz13hxh5b4cMTjhG7nXv9Mwo5As+BH2s4oToCu6
         7r3ncbkKEPYhTHhD/uW4cf6nxO9HCLR2OhieUVIGfpGCq5eRwf9LqaEshpRVaNe/mqUW
         wUwqKmzDOByVFL1fJB/rkefrjl0x02Z09oedF/O0JyQ20eYsB3pPSm+5c/9ZwABcFxss
         rniA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=V5LySrDNIuJfRn6aGIE9UpyfQnEuTeFHcaLHDpOcTzQ=;
        b=pY2j/LcnCTkNIheXZ34/z4ZZUkGyxo6hSlCn2frm9smX/oMDnN23cDMZ1eThXMS9/r
         mIwglGmC/TcMLbynbfw2CvdEGD/9HJvIZCVHHD+0ccxcBBqgTDAEw1uV22cdz1F3X1Tz
         EWRok1fGqv/+tajM4fB9fsYWucIaTbpy6c1ejwlxQdnuTQby3GgZvnTCwHIwoGz8Ag/E
         362XjDz8a+aahDVjVr6FKPhljPiEHE5PvHg5pk6L3uCJAkFZBJo5797oV3AElpwzQayS
         o+JgTaGEyDFO76xot7bk92DEbOoPb3GNcHHSVW2WWd4ZogrL3zl/Vg1vcNscL138e0ib
         ssOQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.38 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp05.blacknight.com (outbound-smtp05.blacknight.com. [81.17.249.38])
        by mx.google.com with ESMTPS id me22si459359ejb.21.2019.04.19.04.13.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Apr 2019 04:13:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.38 as permitted sender) client-ip=81.17.249.38;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.38 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp05.blacknight.com (Postfix) with ESMTPS id EAB2798CB2
	for <linux-mm@kvack.org>; Fri, 19 Apr 2019 11:13:57 +0000 (UTC)
Received: (qmail 9461 invoked from network); 19 Apr 2019 11:13:57 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[37.228.225.79])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 19 Apr 2019 11:13:57 -0000
Date: Fri, 19 Apr 2019 12:13:56 +0100
From: Mel Gorman <mgorman@techsingularity.net>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: Michal Hocko <mhocko@kernel.org>,
	Andrea Arcangeli <aarcange@redhat.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
Subject: Re: [QUESTIONS] THP allocation in NUMA fault migration path
Message-ID: <20190419111356.GK18914@techsingularity.net>
References: <aa34f38e-5e55-bdb2-133c-016b91245533@linux.alibaba.com>
 <20190418063218.GA6567@dhcp22.suse.cz>
 <bb2464c9-dc45-eff1-b9ac-f29105ccd27b@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <bb2464c9-dc45-eff1-b9ac-f29105ccd27b@linux.alibaba.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 18, 2019 at 09:18:15AM -0700, Yang Shi wrote:
> 
> 
> On 4/17/19 11:32 PM, Michal Hocko wrote:
> > On Wed 17-04-19 21:15:41, Yang Shi wrote:
> > > Hi folks,
> > > 
> > > 
> > > I noticed that there might be new THP allocation in NUMA fault migration
> > > path (migrate_misplaced_transhuge_page()) even when THP is disabled (set to
> > > "never"). When THP is set to "never", there should be not any new THP
> > > allocation, but the migration path is kind of special. So I'm not quite sure
> > > if this is the expected behavior or not?
> > > 
> > > 
> > > And, it looks this allocation disregards defrag setting too, is this
> > > expected behavior too?H
> > Could you point to the specific code? But in general the miTgration path
> 
> Yes. The code is in migrate_misplaced_transhuge_page() called by
> do_huge_pmd_numa_page().
> 
> It would just do:
> alloc_pages_node(node, (GFP_TRANSHUGE_LIGHT | __GFP_THISNODE),
> HPAGE_PMD_ORDER);
> without checking if transparent_hugepage is enabled or not.
> 
> THP may be disabled before calling into do_huge_pmd_numa_page(). The
> do_huge_pmd_wp_page() does check if THP is disabled or not. If THP is
> disabled, it just tries to allocate 512 base pages.
> 
> > should allocate the memory matching the migration origin. If the origin
> > was a THP then I find it quite natural if the target was a huge page as
> 
> Yes, this is what I would like to confirm. Migration allocates a new THP to
> replace the old one.
> 
> > well. How hard the allocation should try is another question and I
> > suspect we do want to obedy the defrag setting.
> 
> Yes, I thought so too. However, THP NUMA migration was added in 3.8 by
> commit b32967f ("mm: numa: Add THP migration for the NUMA working set
> scanning fault case."). It disregarded defrag setting at the very beginning.
> So, I'm not quite sure if it was done on purpose or just forgot it.
> 

It was on purpose as migration due to NUMA misplacement was not intended
to change the type of page used. It would be impossible to tell in advance
if locality was more important than the page size from a performance point
of view. This is particularly relevant if the workload is virtualised and
there is an expectation that huge pages are preserved.  I'm not aware of
any bugs whereby there was a complaint that the THP migration caused an
excessive stall. It could be altered of course, but it would be preferred
to have an example workload demonstrating the problem before making a
decision.

-- 
Mel Gorman
SUSE Labs

