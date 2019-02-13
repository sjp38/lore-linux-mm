Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2FB38C282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 15:06:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E7E7D222C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 15:06:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E7E7D222C2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 683408E0003; Wed, 13 Feb 2019 10:06:36 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6304C8E0001; Wed, 13 Feb 2019 10:06:36 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4D4828E0003; Wed, 13 Feb 2019 10:06:36 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id E869C8E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 10:06:35 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id v26so1115504eds.17
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 07:06:35 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=UkQP6RJr6mQTndN2vKj0pb1bUJ0hTLSnjgtAB2OYBuc=;
        b=WQJGvONvqdNCn/zoyCN0n6S7y8dxlalyCKnCj49fpL+PZ08aNlQrY71fpPkc0SHPq2
         4mhOACi2BLzVxfjsAyNofCE32vQfsAAfwKNAqc92yR4SlzUgdUnvQ18KZowsBLMzusIZ
         RrFg0zRA2UH6KI/v+5FMTqemmy1LHl60g5pPSZRhzCFdoxNrbuGf4TzAMbsDZyIj9YKQ
         BAnVSAkmxG5hnV/cYXj6hLHgvvN77/PoGHp7E91/NdWFOMYMCgHwieK8chNOrKkxAtot
         8PBljbp6oTegrKPuoeZPPCHTHcfIdIG1kPPRGkiq991HuIQRrqUdxA22AXxyNxSJYm8q
         Wbrg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: AHQUAuYx9zOiBSPMWRICD0dd3RO72JKtL3q2mdPmHc/86/03uny5SjYZ
	t86pSU+PaLmySlxh2P/7fhFnOuI5oxlf5dQVdCZdlD6BMzh5U5vHmvdeb/6lsjOQZkb3GSTz+xO
	vBZLKwpMY12kJJzY5s6DHvykZ4VprOOkoahg3B6xN7MXAE3LYSOZAjaYSxGTTdcR0Hw==
X-Received: by 2002:a50:88c1:: with SMTP id d59mr779346edd.200.1550070395470;
        Wed, 13 Feb 2019 07:06:35 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYKlrTnwl/pDoaHtPYJbiwEVchxxK75bE7EOQRuJKkPm3bCCJnMCbQTHaCQKunPVAbo0nLt
X-Received: by 2002:a50:88c1:: with SMTP id d59mr779274edd.200.1550070394423;
        Wed, 13 Feb 2019 07:06:34 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550070394; cv=none;
        d=google.com; s=arc-20160816;
        b=YKidFGJFA70UOGb1A8vGRhgim1N/sc0o4yy6iHf1nbnz9eL3Mkw75ZFnmt+ksA3G9E
         UE8dzjDQRQy2VaIlrA4Shn41ZsuYm2G+d7eAp845dDmaAPMgb0TSxUhg2TdZycHv+9D4
         obEJHYstguUbvlsW/gAdf1BeT977aHRQ1Av+UFo9sbAe6FjhR2SZjlnk1zgAW7L/LUGc
         Sip3No82OcFL0fWU+iG2igMhfvCMCNVU03hb2bBIsTUcH4pvxdFv0+/8rqavmvOXmib5
         NocE0O2fp11vPVpTtdGFpfNA4PFSp9MsGcNgEzXSNAZi4Y4+qU7NyxqrlKFWRfOHhyty
         Oi2g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=UkQP6RJr6mQTndN2vKj0pb1bUJ0hTLSnjgtAB2OYBuc=;
        b=pzmgUbkp9yuky51KHBqfsmk8ieuulEtTpZD41Tw8aVvCdxDSY4tjqQt0ZT5XwwJrwo
         3jxebwjjwgUfr4eMH9velM7wqWEbsaapaIYW4aW6VL8/+3izl/iDkRwXcYY5PgWUdrwG
         p8c6iWN+D1RX5Padlor7BRAAlfBCyshYWqjApnrdVwonTLi1N2eIK6XhVJXAOJAr7bIa
         wLlPpgPo6KFD/LDRscXT2Rd2Du1mR8enlffCkDJEFpPtvJB1Gmy9Gf9DM7EKZxgY+kiZ
         zwCSVp1qJkhR4J8VldHSG4yeC5T4NzSmirDltBv8FOApHbuXETYNZLlJ6VCyKVGOM0Up
         qp8w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f15si618990ejb.48.2019.02.13.07.06.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 07:06:34 -0800 (PST)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id AA3C4AE7F;
	Wed, 13 Feb 2019 15:06:33 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id B2BDC1E09CD; Wed, 13 Feb 2019 16:06:32 +0100 (CET)
Date: Wed, 13 Feb 2019 16:06:32 +0100
From: Jan Kara <jack@suse.cz>
To: Christopher Lameter <cl@linux.com>
Cc: Jan Kara <jack@suse.cz>, Jason Gunthorpe <jgg@ziepe.ca>,
	Dan Williams <dan.j.williams@intel.com>,
	Matthew Wilcox <willy@infradead.org>,
	Ira Weiny <ira.weiny@intel.com>, Dave Chinner <david@fromorbit.com>,
	Doug Ledford <dledford@redhat.com>,
	lsf-pc@lists.linux-foundation.org,
	linux-rdma <linux-rdma@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	John Hubbard <jhubbard@nvidia.com>,
	Jerome Glisse <jglisse@redhat.com>,
	Michal Hocko <mhocko@kernel.org>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
Message-ID: <20190213150632.GB26828@quack2.suse.cz>
References: <20190211180654.GB24692@ziepe.ca>
 <20190211181921.GA5526@iweiny-DESK2.sc.intel.com>
 <20190211182649.GD24692@ziepe.ca>
 <20190211184040.GF12668@bombadil.infradead.org>
 <CAPcyv4j71WZiXWjMPtDJidAqQiBcHUbcX=+aw11eEQ5C6sA8hQ@mail.gmail.com>
 <20190211204945.GF24692@ziepe.ca>
 <CAPcyv4jHjeJxmHMyrbRhg9oeaLK5WbZm-qu1HywjY7bF2DwiDg@mail.gmail.com>
 <20190211210956.GG24692@ziepe.ca>
 <20190212163433.GD19076@quack2.suse.cz>
 <01000168e2a26936-eb7cef59-9772-4a76-b7f3-a7fdc864fa72-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <01000168e2a26936-eb7cef59-9772-4a76-b7f3-a7fdc864fa72-000000@email.amazonses.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 12-02-19 16:55:21, Christopher Lameter wrote:
> On Tue, 12 Feb 2019, Jan Kara wrote:
> 
> > > Isn't that already racy? If the mmap user is fast enough can't it
> > > prevent the page from becoming freed in the first place today?
> >
> > No, it cannot. We block page faulting for the file (via a lock), tear down
> > page tables, free pages and blocks. Then we resume faults and return
> > SIGBUS (if the page ends up being after the new end of file in case of
> > truncate) or do new page fault and fresh block allocation (which can end
> > with SIGBUS if the filesystem cannot allocate new block to back the page).
> 
> Well that is already pretty inconsistent behavior. Under what conditions
> is the SIGBUS occurring without the new fault attempt?

I probably didn't express myself clearly enough. I didn't say that SIGBUS
can occur without a page fault. The evaluation of whether a page would be
beyond EOF, page allocation, and block allocation happen only in response
to a page fault...

> If a new fault is attempted then we have resource constraints that could
> have caused a SIGBUS independently of the truncate. So that case is not
> really something special to be considered for truncation.

Agreed. I was just reacting to Jason's question whether an application
cannot prevent page freeing by being aggressive enough.

								Honza

-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

