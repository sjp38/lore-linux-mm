Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4B19DC169C4
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 20:31:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EBEA42083B
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 20:31:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="WF44oOck"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EBEA42083B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 836BE8E00FB; Wed,  6 Feb 2019 15:31:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7E6F78E00F3; Wed,  6 Feb 2019 15:31:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 687CC8E00FB; Wed,  6 Feb 2019 15:31:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 270638E00F3
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 15:31:52 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id g188so5398859pgc.22
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 12:31:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=YbIyUkC8UsSdzZyVesr8tAiigZg7wCHaBbnulVXafGw=;
        b=GsXIUQxL+Te4FEWj7C/bPCdXf5tzLv2OTX2N5v/+qcKyxNwAoBnHJK1GKZinBRIthK
         AHZUk9Ez8WSm3riRJhAsH1t/Kro+/XdLKIKveVc+4PrOTaJWrZAC2PJk+vih9wrD/P0a
         Me4CRLOoZgWu8NTB5LLmw5atDCJSIHr8N1be77jlhXWvz30EuY5O4dbdt3BptC9rlIKL
         /wuRq+s8RADjQqQghp3GgazhGnF3y+SRbJGMjoTfiz+d+jnZ4xTItd+bB7VfTzLScCSQ
         NpcajK36J8zvdNXiH/TkjDuZsbX6pj11bYT3/aJ8G15SdDUOKt6cM+6p2t+QkyOfBO1m
         Ld0A==
X-Gm-Message-State: AHQUAuZNE7iPAcp2Is+dxQqM2vVtPXVfFScFfTx9KbgfECSsshngH8D+
	I5GkB6PLstNNg19JezoETbgplrZoQJ2fYQILhSH5Kcw/eihyhEE8xsH4gKDRbXBbjkIjgl9KX4B
	fe7V+aeoIiLtqUdSB2BbXxudtXqBl2b1cK/QxFdQvaTjikt4WRKv5zW7g1dVZyBj0Mtp5bLyYS7
	pNAl8bP1Elk3nrAMWNDnY3SzorcUTmxVJEPT1GTqUvS23sj/kJH40syN6uJb2P7tW06H1NN3nur
	W+OEjlpRlJDTgD3U4dInvkjqW3C3CJ/PBJ1BTdCzG7f/4AaSh5QvhIOikgryzXJVk4v6dmX7xrd
	KnfLxJJMJ0L+EwspqDJLceKWJ5y4Dm/7ig3NlDostZbOAmPsWPOJO5+81cS6JVoXE234fHeR1kL
	o
X-Received: by 2002:a63:e5d:: with SMTP id 29mr11229126pgo.237.1549485111816;
        Wed, 06 Feb 2019 12:31:51 -0800 (PST)
X-Received: by 2002:a63:e5d:: with SMTP id 29mr11229082pgo.237.1549485111132;
        Wed, 06 Feb 2019 12:31:51 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549485111; cv=none;
        d=google.com; s=arc-20160816;
        b=oqGjBu6JrxAwbhYeH3qe2+Ew5ROPaQWaVf6fjLGShX1RtDF5soXFDE6q0vqy+G8dHP
         1N+YxZ6hgXxVtKNcacukMeoTrDdcrk2Ielfnnd/SdWR/MiMQuYhpcMgx6IurzQMueLYy
         GSKm/29+sbRpKe5k6Q7lJJNNpv4k0tePt6nTReiNgwkanXzSrRUFv4kaIruQouRofPaS
         LznjsjmGGeJLH0k/m+uSPPaMy5VFEWkKR/Fef5fOPrsZWqv4Z6TjoZEX39JnL09pAtcI
         xk7Xz6PzBlzy/KrL6LSfiBQzRcqXyLxSAeBZFJZTaQP2MH/GUk8hzI3CBPa8qv7OU0ay
         Xlsw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=YbIyUkC8UsSdzZyVesr8tAiigZg7wCHaBbnulVXafGw=;
        b=o6NYndHCwD9gbX8j7kIQWVbG0FTqLX3i/u0zAWL33QfqALgjLqsmaWJ52b/vnWim2e
         2mzjDks8IZpkdT/wH8lgWZ3hgTOMShrEawU8oRIMmIYa/9XWktRg940q24ZCyRSrTNHX
         SIS3X5fO8StMqzkaVuSPIHVHk2/8uRwnuCcQVGtauE3Ok0AWwNtvLuYzPIuxaKuBGkxE
         O2uEqUKL85nrHYS25Sia612T2GZHnlWsCA2zRgOWYlAPwoaGjYmcWeaZ5hj7NP7YkzHR
         Aj5xXq0aKGYy2XuEMe1bjqwNOFP57s8aHMRGbbeDvAAPO8cJL46JyaR+VQIbk0HiEYwO
         3xMw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=WF44oOck;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m3sor8148896pll.44.2019.02.06.12.31.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Feb 2019 12:31:51 -0800 (PST)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=WF44oOck;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=YbIyUkC8UsSdzZyVesr8tAiigZg7wCHaBbnulVXafGw=;
        b=WF44oOckEfi+7lA1Db/d7VzHyHF8wSXAwVCN2sZnyLKGdSfzhu5QjxpXFLzdXS9quN
         x3sQ0hdDNxoHrqKLRLDnbsI9uH6uIEvprHN2wrNdZAwEvD4D8RYtsYDw+BlJ76uToxuw
         V2Bsyiy7yX6H3VkpWMcK7A8O61EhbZfmfCdo9MTAC14fUjdhr/0dku3dGYKHd8SImXmM
         iS2Z7UtCllEOAonSZxwM5vvbaCI0tLjRY+pgTY8KGkFJamSTKSaIyb69VM/ohynBuRTG
         nFJOGtmS4mCxTdT2ZofAwFIHN34JJtUBDw/aWpvImlDfGnexoZQqY14FsfLtfICF/D7n
         ezoQ==
X-Google-Smtp-Source: AHgI3IYyYFHm1UB/lEJXyP4bIedLwSbk4vKppJGV+uLvM/DXyuamDSexcWkCjNfC7MybiGjQJRK3ZQ==
X-Received: by 2002:a17:902:eb03:: with SMTP id cw3mr12588301plb.130.1549485110664;
        Wed, 06 Feb 2019 12:31:50 -0800 (PST)
Received: from ziepe.ca (S010614cc2056d97f.ed.shawcable.net. [174.3.196.123])
        by smtp.gmail.com with ESMTPSA id v184sm11025630pfb.182.2019.02.06.12.31.49
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 06 Feb 2019 12:31:50 -0800 (PST)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1grTrJ-0005Ww-5z; Wed, 06 Feb 2019 13:31:49 -0700
Date: Wed, 6 Feb 2019 13:31:49 -0700
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Matthew Wilcox <willy@infradead.org>
Cc: Doug Ledford <dledford@redhat.com>, Christopher Lameter <cl@linux.com>,
	Jan Kara <jack@suse.cz>, Ira Weiny <ira.weiny@intel.com>,
	lsf-pc@lists.linux-foundation.org, linux-rdma@vger.kernel.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>,
	Jerome Glisse <jglisse@redhat.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	Michal Hocko <mhocko@kernel.org>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
Message-ID: <20190206203149.GI12227@ziepe.ca>
References: <20190205175059.GB21617@iweiny-DESK2.sc.intel.com>
 <20190206095000.GA12006@quack2.suse.cz>
 <20190206173114.GB12227@ziepe.ca>
 <20190206175233.GN21860@bombadil.infradead.org>
 <47820c4d696aee41225854071ec73373a273fd4a.camel@redhat.com>
 <01000168c43d594c-7979fcf8-b9c1-4bda-b29a-500efe001d66-000000@email.amazonses.com>
 <20190206194055.GP21860@bombadil.infradead.org>
 <a9df9be75966f34f55f843a3cd7e1ee7d497c7fa.camel@redhat.com>
 <20190206202021.GQ21860@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190206202021.GQ21860@bombadil.infradead.org>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 06, 2019 at 12:20:21PM -0800, Matthew Wilcox wrote:
> On Wed, Feb 06, 2019 at 03:16:02PM -0500, Doug Ledford wrote:
> > On Wed, 2019-02-06 at 11:40 -0800, Matthew Wilcox wrote:
> > > On Wed, Feb 06, 2019 at 07:16:21PM +0000, Christopher Lameter wrote:
> > > > 
> > > > though? If we only allow this use case then we may not have to worry about
> > > > long term GUP because DAX mapped files will stay in the physical location
> > > > regardless.
> > > 
> > > ... except for truncate.  And now that I think about it, there was a
> > > desire to support hot-unplug which also needed revoke.
> > 
> > We already support hot unplug of RDMA devices.  But it is extreme.  How
> > does hot unplug deal with a program running from the device (something
> > that would have returned ETXTBSY)?
> 
> Not hot-unplugging the RDMA device but hot-unplugging an NV-DIMM.
> 
> It's straightforward to migrate text pages from one DIMM to another;
> you remove the PTEs from the CPU's page tables, copy the data over and
> pagefaults put the new PTEs in place.  We don't have a way to do similar
> things to an RDMA device, do we?

I've long said it is reasonable to have an emergency hard revoke for
exceptional error cases - like dis-orderly hot unplug and so forth.

However, IHMO a orderly migration should rely on user space to
co-ordinate the migration and the application usages, including some
user space driven scheme to assure forward progress..

.. and you are kind of touching on my fear here. revoke started out as
only being for ftruncate. Now we need it for data migration - how soon
before someone wants to do revoke just to re-balance
usage/bandwidth/etc between NVDIMMS? 

That is now way outside of what a RDMA using system can reasonably
tolerate. How would a system designer prevent this?

Again, nobody is going to want a design where RDMA applications are
under some undefined threat of SIGKILL - which is where any lease
revoke idea is going. :( 

The priority of systems using RDMA is almost always to keep the RDMA
working right as it is the often key service the box is providing.

Jason

