Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C2D6BC43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 22:07:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7E7B6214AE
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 22:07:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7E7B6214AE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 186188E0003; Tue, 12 Mar 2019 18:07:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 10F4C8E0002; Tue, 12 Mar 2019 18:07:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EF1028E0003; Tue, 12 Mar 2019 18:07:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id A84C88E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 18:07:30 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id a72so4580780pfj.19
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 15:07:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=IUtDGT2lS0pgzysm+OndZotg4K2CJmGwaK4+2oChHNQ=;
        b=VCAzMcTWgTztGjWpkSuv7+pkFblocklMYQcWk4xdUMJBF3B9lkepP11VyP7Tu23jos
         HRUw9duAOf2E2PbRjdNhk2PJeIyrpukXfchuXC5E/9PZSIs/rKHMACOfJCry9Oyy3/BQ
         JjnnnQpv6cjjSnKxoRA4a6jjj8YRiHCZBOV/+PwN9iLH1mFquQrTIICCLj1A/kGGrvvS
         PkGJFKcMewbvP5NMpT5jI4Ng2m5eoZ/P76r4+EmOvWOoK747rqbUVaJ28Cu7qJNyGwyq
         VYyNurY4aVo7QUJPfx6oGzUYGCfNRGUKyszPr0U/ZiTPvmhNcADlakdaAnTtBDGxFbUr
         EW+Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAWwN5KS8uuqTCb2gvijTghbhT/hMUUHyNw068V7n2hliJnzR2gj
	SvqwYr0eaVNG3AGiV6UKb1L2UifawcxZ2ctEPfeMrbysNCKwKg5Ate+99h1R1VKp92OXllgrLlD
	vBeod1ePJJW5sLHBvWeSeOAELNoj1CsrT+25WyloCF9DnPf+h3ArTKrSWbBICQPwMvQ==
X-Received: by 2002:aa7:8c13:: with SMTP id c19mr4404864pfd.247.1552428450086;
        Tue, 12 Mar 2019 15:07:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzvPIT/REMfVfB/+OcdHMES33L1LcODb97D61Mx3BW3k9Kx7GiUEZGeQKKDaK5sR06eZJhS
X-Received: by 2002:aa7:8c13:: with SMTP id c19mr4404813pfd.247.1552428449153;
        Tue, 12 Mar 2019 15:07:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552428449; cv=none;
        d=google.com; s=arc-20160816;
        b=RnKwv4DRYSv3ypcbWvuA32U8+NpvLQFyDPtFvSmEYCI0suL10nS0i/xujYxeFYtRPk
         JWPGuNYuafWfH2Y6u7JUxiflZbuSPdqGz8vkNWh+Gmv9Ya6Qq3Y5URa6Hi24s4v4MTKT
         fWUu17lns5AhvWkLxNDURKSLD0xkB4ceGifiOoCl26ZdDAXuqvDYiKAFLlQEc2KG+J/K
         s5eaqpHcSAG6i3ScMlMWqUHkFP+82eYBOT0IPMs6DYsTs0aQQPWfZNM0v8NWMe2P444B
         tA/sA8vWFPi2Z/wuyZ7Qg84JdOLT9rGSH4dg2aw4zTFN+mZ65o/YsL15WBPSFFJ4Ojpn
         ucag==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=IUtDGT2lS0pgzysm+OndZotg4K2CJmGwaK4+2oChHNQ=;
        b=vH0SJ1KgnJql+ClwJq+Ty+YIbgIYQCm2195jfmXAvMagHMOoHRgqccQyfeTl5ezBbd
         h9XvT35nwVcyJc8dAZIyj/0Mjsu+6uRC3Sb10jfjW3KgPbYOdwUn/cG0lsJLvKI3rvgI
         VbSvqguuse7mp+LW9aCj+Khnx2tTTKXlTr2E47P7TE/f8a4RgvsnM+tpLCHFIdbSnZou
         GZ06ZyWNrE4Lv4urNzrkf/BSWl8RpQZJEojIhk9Jr8tmImLIjJoU+BdH9bBQ/2bfTrWU
         p/A3JncQvw1zw4+Lrm4B4JkLdIzHRoCsCiN9iWvduTQspV+nseJ+GJvBXZUW09Q4VJqw
         2Kww==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id c24si8699389pgj.502.2019.03.12.15.07.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 15:07:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 3B77E25A;
	Tue, 12 Mar 2019 22:07:28 +0000 (UTC)
Date: Tue, 12 Mar 2019 15:07:27 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Alexander Duyck <alexander.h.duyck@linux.intel.com>, linux-mm@kvack.org,
 sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-nvdimm@lists.01.org, davem@davemloft.net,
 pavel.tatashin@microsoft.com, mingo@kernel.org,
 kirill.shutemov@linux.intel.com, dan.j.williams@intel.com,
 dave.jiang@intel.com, rppt@linux.vnet.ibm.com, willy@infradead.org,
 vbabka@suse.cz, khalid.aziz@oracle.com, ldufour@linux.vnet.ibm.com,
 mgorman@techsingularity.net, yi.z.zhang@linux.intel.com
Subject: Re: [mm PATCH v6 6/7] mm: Add reserved flag setting to
 set_page_links
Message-Id: <20190312150727.cb15cbc323a742e520b9a881@linux-foundation.org>
In-Reply-To: <20181205204247.GY1286@dhcp22.suse.cz>
References: <154361452447.7497.1348692079883153517.stgit@ahduyck-desk1.amr.corp.intel.com>
	<154361479877.7497.2824031260670152276.stgit@ahduyck-desk1.amr.corp.intel.com>
	<20181205172225.GT1286@dhcp22.suse.cz>
	<19c9f0fe83a857d5858c386a08ca2ddeba7cf27b.camel@linux.intel.com>
	<20181205204247.GY1286@dhcp22.suse.cz>
X-Mailer: Sylpheed 3.6.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 5 Dec 2018 21:42:47 +0100 Michal Hocko <mhocko@kernel.org> wrote:

> > I got your explanation. However Andrew had already applied the patches
> > and I had some outstanding issues in them that needed to be addressed.
> > So I thought it best to send out this set of patches with those fixes
> > before the code in mm became too stale. I am still working on what to
> > do about the Reserved bit, and plan to submit it as a follow-up set.
> 
> >From my experience Andrew can drop patches between different versions of
> the patchset. Things can change a lot while they are in mmotm and under
> the discussion.

It's been a while and everyone has forgotten everything, so I'll drop
this version of the patchset.

