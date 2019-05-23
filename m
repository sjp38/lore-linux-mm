Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 89ADCC282DD
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 19:37:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 408A42177E
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 19:37:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="UfpXqxnk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 408A42177E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A8C4D6B02AA; Thu, 23 May 2019 15:37:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A3E676B02AC; Thu, 23 May 2019 15:37:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 92C866B02AD; Thu, 23 May 2019 15:37:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 71D016B02AA
	for <linux-mm@kvack.org>; Thu, 23 May 2019 15:37:06 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id p190so6386195qke.10
        for <linux-mm@kvack.org>; Thu, 23 May 2019 12:37:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=EvB2oEdix8izGKCkl98CmLnxVEgkJ+2l0HrrW4Cnk4Y=;
        b=qKzYJVMb/zqWJgdkuEvzIv/dNyJ7qSFoej27npYekam87+vmCgUwyiMBw9AuXpqcz0
         axjlBjIG9Mbv/09j9lLfbvxU9HAk4Ch8gWQi4t6gHFGnjqUYY3MrzrSD0Z1HpHUZw7zd
         5apztgSnADkMhJ/7YyinTIeaCjrXwJLmIjCN3qkbqNwoVb6YJaOUWsuxIFhuVKb66X72
         Yea/vjGAHpwRt7VLHR79R4s+Lv4AYmLofkWzeOwMJMKLD+jUlzgNgLZ1L2bLRStHVwrX
         UKd13KO7aYkmY9ZUhjDOq1yP1skzoRk9RIZ8YxBriOFWNKlusOpTGQmdBk93ZrodPAZj
         oGow==
X-Gm-Message-State: APjAAAXekCK91P6sF5M+u7AP53bocvQkMfsTxV+tyQr48fybFdE1QpTr
	0aO+634vwmA3kC/zhZdLFsut2u892ggGcgK9TofBPzWZRcyMYAfpnpTAGn0vEd74jeLQyOPEM+W
	R+WvLPvctvnUSlRLsOtRRKyVJMXzdtsKpkhoerFq9VffJ921zo4UlplESIakzXK/sSQ==
X-Received: by 2002:ae9:e806:: with SMTP id a6mr60601531qkg.247.1558640226195;
        Thu, 23 May 2019 12:37:06 -0700 (PDT)
X-Received: by 2002:ae9:e806:: with SMTP id a6mr60601496qkg.247.1558640225647;
        Thu, 23 May 2019 12:37:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558640225; cv=none;
        d=google.com; s=arc-20160816;
        b=mGLIa/zF+Y6B/Ge/iA30PUYmsQVuAHE0b13Q5yo4iBgoJ+7W6Ysb9ahb+e4aoi8WjJ
         YjVKC+zNORknjAShzjHjmLrjXXFuTpkBYVkEkIpLcgAHPjDngJ7m1/pi0O1SY7EvMU2Y
         tT1m7NTWP/hNW4tHB209Ce+jdqiFcCOx9fbyoswC55hvaLIYQks1ci5lE3a8PCl+TbEq
         dAnTz7DQ1Ljp0azY15kjFAe8EbOIBgrDzqQ9k49eixZfV5vhDNJSbsyDiHjbFlp//fqM
         i0IDC1eaDRhH/fLJQJ76QdgLfNreVHNpqPbiQqVnsMnK5PkW6jsr4kgar9SG2ZcF5Wpz
         1vfw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=EvB2oEdix8izGKCkl98CmLnxVEgkJ+2l0HrrW4Cnk4Y=;
        b=OpxDb1viRk483ayL4EUnJauk1mnWcn5x+fWRKqMy0WcClmTU+ei3sazY6g1lRF9hOd
         YklPX4S5drDBSBBaIGQqrgQkep8oDMDVRXZCaCFgEiK5BmDtpiJEkoJnXIXB/3duFkpo
         nLkfrJ63/QozE0uJrzAGBatKuF7259ygKZQUBPOEVbm2m9szZ/76jEikXtY9/h/3Dpba
         zXBmzJz44bVJ4pTQ81p5lOQcO+PF8J3mQoQJFMAgkWLC9Gq1bvw9SFg1Ot7sVzFPYdEp
         njZmYx+V+dkHTNz7HOE+M3sITbaEfHYILrJ6sV4wkjUdeeqTaHuUG8v2YLLVPok0Rwbe
         vYkw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=UfpXqxnk;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c5sor142359qtp.62.2019.05.23.12.37.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 May 2019 12:37:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=UfpXqxnk;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=EvB2oEdix8izGKCkl98CmLnxVEgkJ+2l0HrrW4Cnk4Y=;
        b=UfpXqxnkWDaeaaMCa66rkawZsy7d3VU8+Y4fiL6RCiHgxXiOAlS3lxadX42iz4hl+M
         BIkIHbLj+ye2OmlcBBji/RjpTpPAk1hYv6g6D1K/w1oZN0xrtKLWtx95M6bwxcHoudgZ
         LTE3fOtWAmcT5VE45VMIhIvFoG+07u1HBIcDuZZQNpfYs/WJC8yMoLOU/o6yns6gbHyh
         da23t12u1Zi2CytLjFaaqChQILykLUvixJtBowukob56QB9gAZRPMHkq3K4suDSvzCK3
         zp2oNMk2ARP7Ha6oXysTJv/ctxhnMVCiaedJEQ9BWmPCe4RT0uqCdknX2mfBR3uygiYX
         Di9w==
X-Google-Smtp-Source: APXvYqxJkBFJ4HgvZM38oeTFaXtBNor24nYI7KEJ+EprkXwXo4IbuqdcjGctpDTQXlmC7qxbJGyYAg==
X-Received: by 2002:ac8:6750:: with SMTP id n16mr58786519qtp.142.1558640225374;
        Thu, 23 May 2019 12:37:05 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-49-251.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.49.251])
        by smtp.gmail.com with ESMTPSA id d58sm194218qtb.11.2019.05.23.12.37.04
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 23 May 2019 12:37:04 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hTtWR-0000xZ-Fj; Thu, 23 May 2019 16:37:03 -0300
Date: Thu, 23 May 2019 16:37:03 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: John Hubbard <jhubbard@nvidia.com>
Cc: linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>
Subject: Re: [RFC PATCH 00/11] mm/hmm: Various revisions from a locking/code
 review
Message-ID: <20190523193703.GI12159@ziepe.ca>
References: <20190523153436.19102-1-jgg@ziepe.ca>
 <6ee88cde-5365-9bbc-6c4d-7459d5c3ebe2@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6ee88cde-5365-9bbc-6c4d-7459d5c3ebe2@nvidia.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 23, 2019 at 12:04:16PM -0700, John Hubbard wrote:
> On 5/23/19 8:34 AM, Jason Gunthorpe wrote:
> > From: Jason Gunthorpe <jgg@mellanox.com>
> > 
> > This patch series arised out of discussions with Jerome when looking at the
> > ODP changes, particularly informed by use after free races we have already
> > found and fixed in the ODP code (thanks to syzkaller) working with mmu
> > notifiers, and the discussion with Ralph on how to resolve the lifetime model.
> > 
> > Overall this brings in a simplified locking scheme and easy to explain
> > lifetime model:
> > 
> >   If a hmm_range is valid, then the hmm is valid, if a hmm is valid then the mm
> >   is allocated memory.
> > 
> >   If the mm needs to still be alive (ie to lock the mmap_sem, find a vma, etc)
> >   then the mmget must be obtained via mmget_not_zero().
> > 
> > Locking of mm->hmm is shifted to use the mmap_sem consistently for all
> > read/write and unlocked accesses are removed.
> > 
> > The use unlocked reads on 'hmm->dead' are also eliminated in favour of using
> > standard mmget() locking to prevent the mm from being released. Many of the
> > debugging checks of !range->hmm and !hmm->mm are dropped in favour of poison -
> > which is much clearer as to the lifetime intent.
> > 
> > The trailing patches are just some random cleanups I noticed when reviewing
> > this code.
> > 
> > I expect Jerome & Ralph will have some design notes so this is just RFC, and
> > it still needs a matching edit to nouveau. It is only compile tested.
> > 
> 
> Thanks so much for doing this. Jerome has already absorbed these into his
> hmm-5.3 branch, along with Ralph's other fixes, so we can start testing,
> as well as reviewing, the whole set. We'll have feedback soon.

Yes, I looked at Jerome's v2's and he found a few great fixups.

My only dislike is re-introducing a READ_ONCE(mm->hmm) when a major
point of this seris was to remove that use-after-free stuff. 

But Jerome says it is a temporary defect while he works out some cross
tree API stuff.

Jason

