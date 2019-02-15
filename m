Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5CFA7C43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:00:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 164A22192C
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:00:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="aC851/E4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 164A22192C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ABE358E0003; Fri, 15 Feb 2019 17:00:34 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A6F558E0001; Fri, 15 Feb 2019 17:00:34 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 985328E0003; Fri, 15 Feb 2019 17:00:34 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 589008E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 17:00:34 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id i5so7038769pfi.1
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 14:00:34 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=jsHka/kK1Hc1xjCHVh5Lpzl6dCeI0g7HTo9LL4LV7v8=;
        b=Irw/D+WL+W3nm1GxU3BGz+g5vZIt8nqY7gb1WyGTwiFchHnl4SOTDKXV8KLgZpzldo
         nZPIZG0PemNrrAzjel/0BCG/sNH0CTQMNXI9k/2fhurERiPUtlsKV/tT9ao4IuAOe5+8
         spzmJHM3xbzw982AJs+kadMnbeXgF3aH+aMNnwka2v/Cu0v7YZNhaVAH9rggOItQ63SE
         LoXhawL6Rd4e3eYJ/aCfOjPn9zxW7Q5UN/dHOIvG1/aaZLviaWDB/15VLk9yu372glAY
         n1xJmhszbroyK8rPYJCBUCwAr3FWeJMeiDfOMYloHSMK+Z3Dt15oeEDhovdGH3xxAC7W
         EKOw==
X-Gm-Message-State: AHQUAubKNCT2dJXyv9uBJH7KLMmDoyfMcsUkQRfBbfmBDNXsS0+OXQOx
	wRbiWTMI27THfIuH+SFsB70D7JXiuJogBHUzueiIjWOI4pgcselpo5yu3wLdJ8fgONzM8LV432f
	rJL0IE3JvRvQeUjST+TATMj/V0T2pJ9NZL2lbv6aaREBijfFbOdqBZveh2UrfaChj94NrB87LW9
	Yia24V0S0cnKEOjRUio63bmDrDInh+yeoEiam8Fo9LO2pjUEmricuvIeVT2xdx8WRPKbfNsjf2q
	Xv3CldTgxIa0QbfJcsbbyVvL034aCT9peUiNHFItlXdr0E9xV1bX5tVJCDxRWH39YfCZWiSC1wl
	/6vcdaFbGY7Z9v23F/OXl3gBS8qFAWIpgLK3/AUNtP4lEOBINU7PHUd9NcTELreVK4FMpBe4aHO
	J
X-Received: by 2002:a63:234c:: with SMTP id u12mr2911692pgm.282.1550268033962;
        Fri, 15 Feb 2019 14:00:33 -0800 (PST)
X-Received: by 2002:a63:234c:: with SMTP id u12mr2911628pgm.282.1550268033273;
        Fri, 15 Feb 2019 14:00:33 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550268033; cv=none;
        d=google.com; s=arc-20160816;
        b=KNs4tiTn62fReIGARGmbLPC0aOh5CK4E9AUrhh4A98sA4Vkof4VVosLVbx6xCoozkT
         LIWT9+iyPEV6/hhHQD9FAXe0MI+gUFszTeQ+KlnPa6tSoCJNMSQEMBjjZZ67oPQ0AN80
         GLWtrDSInAFPfKgK06OzBW13WM90C/r3wB7VhwcwRIXzI1rj9KtVPC+tn+2DaWZWrK28
         NMY1ypZiSkTaisC/gLHElb70emVlfu2jb7TZ+35G3K+nEr8SZAr7y0AaEC+B2kccDLXF
         Oxl/PTpU90s/LeGRiQcxTjaZEOTvkaxUIZXf1WPdRWid54IMEdh7eWXtdyZuektiTW/8
         eBAg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=jsHka/kK1Hc1xjCHVh5Lpzl6dCeI0g7HTo9LL4LV7v8=;
        b=NwgShJ2qtAyLMwIglg/B8nROQlGzIgT3ZEaDOvJMfRai05RNp3nKGxHoqH7W2t2DFM
         kfUE/i11iPvnvFSDsclA2LD14E04ZDkiOKE8tQOr1BPZsNGxMWRK5CVzheLgiA+a2ZGV
         PoZkS3JBnZbc8isSzZpzCTwC8yvG1sco7Kwx/ojxaxLWS2FW96lKDULinvOzaArMTMBv
         s1JujTDPQTMtLT53TK8Gy6OPWyatGgXoz9zY0+YJdi3gBgYQkvcTYy31N2Dl/+FU38hp
         DNXciSYv98SRPKezShSfhxy3pVl1ciFMlN+mTouvPYPn/3cdNr+WrVELi0qlUGt9WZLh
         UkzA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b="aC851/E4";
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p4sor10306211plk.3.2019.02.15.14.00.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Feb 2019 14:00:33 -0800 (PST)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b="aC851/E4";
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=jsHka/kK1Hc1xjCHVh5Lpzl6dCeI0g7HTo9LL4LV7v8=;
        b=aC851/E4mady6LQaldgvGYPai38QXy26mlgQMnBDqRtYx4sMmjhU5EAJdHh23umudw
         l3OCVLiijDnfppfLru7s5ESK6O1Jmtm19v4EOlfVj2MaC9u5cJk/EKoiGKGRGER5x4AN
         NUmhLgBvYNvr4wTZgHB/+BkA23fV6GuUXhUN/BzoWh1+uwwv81E5u/73Oqnlr92C5ELJ
         JGWhpsAOmFAX6W+6bhZzMuMiSk5VUydE9KKArkm83h9nKv4Rto7UdLmGyPkjwLi8Bq1F
         t4dM93ZaiTH3XY9Hk+Ew8j+TxpsDLeM4R4GZy4Yo9leexXMkv6gZBrLOZFeyoT8sFbd5
         7zhA==
X-Google-Smtp-Source: AHgI3IZdk55m0XUf5MkveAV8ukx2l8BlNFGqlus+3mIgurgngv1IVfVo9qirGnqTm6hZAZJmXRoUYw==
X-Received: by 2002:a17:902:1022:: with SMTP id b31mr12244861pla.141.1550268032901;
        Fri, 15 Feb 2019 14:00:32 -0800 (PST)
Received: from ziepe.ca (S010614cc2056d97f.ed.shawcable.net. [174.3.196.123])
        by smtp.gmail.com with ESMTPSA id g10sm7663129pgo.64.2019.02.15.14.00.32
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 15 Feb 2019 14:00:32 -0800 (PST)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1gulX5-0001Sw-ML; Fri, 15 Feb 2019 15:00:31 -0700
Date: Fri, 15 Feb 2019 15:00:31 -0700
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Christopher Lameter <cl@linux.com>
Cc: Matthew Wilcox <willy@infradead.org>,
	Dave Chinner <david@fromorbit.com>,
	Jerome Glisse <jglisse@redhat.com>,
	Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>,
	Doug Ledford <dledford@redhat.com>, Ira Weiny <ira.weiny@intel.com>,
	lsf-pc@lists.linux-foundation.org,
	linux-rdma <linux-rdma@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	John Hubbard <jhubbard@nvidia.com>,
	Michal Hocko <mhocko@kernel.org>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
Message-ID: <20190215220031.GB8001@ziepe.ca>
References: <20190211102402.GF19029@quack2.suse.cz>
 <CAPcyv4iHso+PqAm-4NfF0svoK4mELJMSWNp+vsG43UaW1S2eew@mail.gmail.com>
 <20190211180654.GB24692@ziepe.ca>
 <20190214202622.GB3420@redhat.com>
 <20190214205049.GC12668@bombadil.infradead.org>
 <20190214213922.GD3420@redhat.com>
 <20190215011921.GS20493@dastard>
 <01000168f1d25e3a-2857236c-a7cc-44b8-a5f3-f51c2cfe6ce4-000000@email.amazonses.com>
 <20190215180852.GJ12668@bombadil.infradead.org>
 <01000168f26d9e0c-aef3255a-5059-4657-b241-dae66663bbea-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <01000168f26d9e0c-aef3255a-5059-4657-b241-dae66663bbea-000000@email.amazonses.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 15, 2019 at 06:31:36PM +0000, Christopher Lameter wrote:
> On Fri, 15 Feb 2019, Matthew Wilcox wrote:
> 
> > > Since RDMA is something similar: Can we say that a file that is used for
> > > RDMA should not use the page cache?
> >
> > That makes no sense.  The page cache is the standard synchronisation point
> > for filesystems and processes.  The only problems come in for the things
> > which bypass the page cache like O_DIRECT and DAX.
> 
> It makes a lot of sense since the filesystems play COW etc games with the
> pages and RDMA is very much like O_DIRECT in that the pages are modified
> directly under I/O. It also bypasses the page cache in case you have
> not noticed yet.

It is quite different, O_DIRECT modifies the physical blocks on the
storage, bypassing the memory copy. RDMA modifies the memory copy.

pages are necessary to do RDMA, and those pages have to be flushed to
disk.. So I'm not seeing how it can be disconnected from the page
cache?

Jason

