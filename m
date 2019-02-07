Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3BB76C282C2
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 17:26:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E65A221908
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 17:26:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="f+z/qYP9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E65A221908
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 774E98E0054; Thu,  7 Feb 2019 12:26:25 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 71B4F8E0002; Thu,  7 Feb 2019 12:26:25 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 59F188E0054; Thu,  7 Feb 2019 12:26:25 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 165DB8E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 12:26:25 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id y8so359651pgq.12
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 09:26:25 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=XZU6LvkaN2jhCFSZgIMgr5MnScYaXECe3XEiWuxzLMs=;
        b=ScCiXKWxilkQzwP7WDnUMc3KMNu8MyjIYFrTpKZ+urLTw/xXYIoRoun9vpKpZ6eyow
         5yoHSK6MGqyzYuxDwU33xpP81x2uDF8cAL40M2vOtdjB3LIOhrE4RgaXYvZKxQ3VKOHT
         vie+m+YltzWFuLSsngOVVMuA7cvmprQRVbL9VpjyCt7q/1fkbTKFhSPFnGKQVYdyrNVD
         TO3tOaqY7Sh8vSQn0nI6qMyrQsXKMz9XIl8lnoZS/jeHmIxf0M13FAz9undjG95h3y7Z
         eCjEyDPQ0c32ZZGdGc6DpAK3/UB2oxp4ERzxKkqH8I6J/hRjb7OMyY1Aas/+RlvwMepA
         nf3Q==
X-Gm-Message-State: AHQUAuagTgpSVo6n32qcRdTz0E2UbYIfBxVY1mm0CRwUWF6XV1tkLfQM
	ktIlJC4NPf1R0PVFl53tznxeT1MrMA6LV9iqols5TtPhf24Ei4jSZuMx71ohYkZJ6wAlZySw2zk
	NY5qKazJaLLUj7uCdsv4pzNJFvoprLW0btF2I22HHQZKoCe5G2fVqzz48pbTqS8rImxTW1Ov8/1
	Z8/sgJECzs9M5wvF0G1vAG6eUblK6jhRQ86FzIV61053Jjw5ZcXObdUonWFhM5leIkSY3MROZpF
	rhAL0UnL6+hZf28hVH/QTwNbST+hdMhnqI214rgBrrTgAMeBhTIGUnt+C7QNfp6j1t6w4/B1Yrk
	XCarRL0AEG7VaCNc1oiakx149UDX60AR9TxagTyiL/qlYjH/fgP1QAtmy19xVixlvT0O21sZsgn
	u
X-Received: by 2002:a62:6b8a:: with SMTP id g132mr17329316pfc.201.1549560384671;
        Thu, 07 Feb 2019 09:26:24 -0800 (PST)
X-Received: by 2002:a62:6b8a:: with SMTP id g132mr17329249pfc.201.1549560383992;
        Thu, 07 Feb 2019 09:26:23 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549560383; cv=none;
        d=google.com; s=arc-20160816;
        b=ljyHLPp2u6b+Cd55u9IFWtO0Hov5wBBsTrZ/dNZCew3WWgEbohWpaCuhdZ1XQAVQne
         pmct4vgkAuFtizKZjOKBXmtSgjk5XxxvyO4MT5cvUa2x5orhE9Uiuh1rNMuyx35+B8HK
         OHkUgH0c6qIORq0aKznCxBEv+tFeepMntBaLL9Ed7+e5bXpwIiPBADILS0o6lR987zbh
         zh3/x/V7g2TZTDDjRNAImjmUmQcNgzzHdgq3uZPdMbDEsExVNGHrFc/VTLBl5u3pKDTJ
         O2XLxXokad2Lr2+SLhYxvP/jmOchB92OPWSpIzoT1aT6i0Nmccw1X5Ax4cgvEMKSEIwn
         FB7A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=XZU6LvkaN2jhCFSZgIMgr5MnScYaXECe3XEiWuxzLMs=;
        b=dSfKqMePZ18+fguYAPGCBLBaQUxtu+lzWefG6k6AjTi0rNfmfVPPTBJEIxJ7MVi/Wp
         OT6DkzAWQJDWatnuZl3yLenguITOJtVh6kyXNlWKJFuW7DrUhyISz0mYtOml5EDR+bFH
         Oi7m8t2FnOBCupV7V0xUczDQvYmVquLsadx6g51FMK2e0Es/KkV8tWOpjMSTurF0Szsj
         lokZ0LQU7HVvjYwc+1pb5bnmpFqT0HZFDQImO2j/UNylDbmXBZ2S6kBkTGjR5a5j0Bak
         loibf3Z9zakTWaJ1c7eaI5/8zLcZrwDEtBSfmiYMdXWm3Yp1LJIJaukA9h8GDmIokfhi
         PFcA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b="f+z/qYP9";
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d188sor15674250pfg.59.2019.02.07.09.26.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Feb 2019 09:26:23 -0800 (PST)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b="f+z/qYP9";
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=XZU6LvkaN2jhCFSZgIMgr5MnScYaXECe3XEiWuxzLMs=;
        b=f+z/qYP9N5eaLh+NtbAraU7ZdjWZ0fB9Nzko1J1OmZEZs6YBM0Ju6sCeAdaQ/S8xX+
         +dBlR0k5ymDXQOLJI3gZf0KA7i1Mr2rGj8G+FHl/556LaWylKN6nOnvF2ykEVGb/HLct
         FUJzV+UfUnmzGhcX6gd58Wcv/a+wanY1UfAgvSo90KcUWga6TpNrD877sQ/IfzPELco7
         Ypn8GPPRUE6rxfRjmbuHRW7NqrCR8UFnbowCsXW4NGu5RfyktcjXbs6OGEeScgrOscYS
         cPyiMhashnNjp/FUWKi1zMsXPcK2T96DIZyIswM27F/SQQWVrQOReIfX36euoDgDRSAD
         6IAQ==
X-Google-Smtp-Source: AHgI3IZCSHH2roxErEcrj1a3hl5oVQyNWv7+FysWSWfK6w7as45SE1HFpz9K7/grMKXoyXDTuN5fDw==
X-Received: by 2002:a62:1e45:: with SMTP id e66mr17130708pfe.152.1549560383655;
        Thu, 07 Feb 2019 09:26:23 -0800 (PST)
Received: from ziepe.ca (S010614cc2056d97f.ed.shawcable.net. [174.3.196.123])
        by smtp.gmail.com with ESMTPSA id 15sm16445723pfs.113.2019.02.07.09.26.23
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 07 Feb 2019 09:26:23 -0800 (PST)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1grnRO-0001pT-Gm; Thu, 07 Feb 2019 10:26:22 -0700
Date: Thu, 7 Feb 2019 10:26:22 -0700
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Matthew Wilcox <willy@infradead.org>
Cc: Doug Ledford <dledford@redhat.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	Christopher Lameter <cl@linux.com>, Jan Kara <jack@suse.cz>,
	Ira Weiny <ira.weiny@intel.com>, lsf-pc@lists.linux-foundation.org,
	linux-rdma <linux-rdma@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	John Hubbard <jhubbard@nvidia.com>,
	Jerome Glisse <jglisse@redhat.com>,
	Michal Hocko <mhocko@kernel.org>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
Message-ID: <20190207172622.GF22726@ziepe.ca>
References: <20190206173114.GB12227@ziepe.ca>
 <20190206175233.GN21860@bombadil.infradead.org>
 <47820c4d696aee41225854071ec73373a273fd4a.camel@redhat.com>
 <01000168c43d594c-7979fcf8-b9c1-4bda-b29a-500efe001d66-000000@email.amazonses.com>
 <20190206210356.GZ6173@dastard>
 <20190206220828.GJ12227@ziepe.ca>
 <0c868bc615a60c44d618fb0183fcbe0c418c7c83.camel@redhat.com>
 <CAPcyv4hqya1iKCfHJRXQJRD4qXZa3VjkoKGw6tEvtWNkKVbP+A@mail.gmail.com>
 <bfe0fdd5400d41d223d8d30142f56a9c8efc033d.camel@redhat.com>
 <20190207172405.GY21860@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190207172405.GY21860@bombadil.infradead.org>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 07, 2019 at 09:24:05AM -0800, Matthew Wilcox wrote:
> On Thu, Feb 07, 2019 at 11:25:35AM -0500, Doug Ledford wrote:
> > * Really though, as I said in my email to Tom Talpey, this entire
> > situation is simply screaming that we are doing DAX networking wrong. 
> > We shouldn't be writing the networking code once in every single
> > application that wants to do this.  If we had a memory segment that we
> > shared from server to client(s), and in that memory segment we
> > implemented a clustered filesystem, then applications would simply mmap
> > local files and be done with it.  If the file needed to move, the kernel
> > would update the mmap in the application, done.  If you ask me, it is
> > the attempt to do this the wrong way that is resulting in all this
> > heartache.  That said, for today, my recommendation would be to require
> > ODP hardware for XFS filesystem with the DAX option, but allow ext2
> > filesystems to mount DAX filesystems on non-ODP hardware, and go in and
> > modify the ext2 filesystem so that on DAX mounts, it disables hole punch
> > and ftrunctate any time they would result in the forced removal of an
> > established mmap.
> 
> I agree that something's wrong, but I think the fundamental problem is
> that there's no concept in RDMA of having an STag for storage rather
> than for memory.
> 
> Imagine if we could associate an STag with a file descriptor on the
> server.  The client could then perform an RDMA to that STag.  On the
> server, we'd need lots of smarts in the card and in the OS to know how
> to treat that packet on arrival -- depending on what the file descriptor
> referred to, it might only have to write into the page cache, or it
> might set up an NVMe DMA, or it might resolve the underlying physical
> address and DMA directly to an NV-DIMM.

I think you just described ODP MRs.

Jason

