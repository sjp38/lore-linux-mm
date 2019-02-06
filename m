Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 34179C169C4
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 18:35:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E678620844
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 18:35:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="vANjs2HZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E678620844
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 980888E00EA; Wed,  6 Feb 2019 13:35:09 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 908618E00E8; Wed,  6 Feb 2019 13:35:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7D0558E00EA; Wed,  6 Feb 2019 13:35:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 39C928E00E8
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 13:35:09 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id j132so4094659pgc.15
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 10:35:09 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=qI29K96IrArheGtskdty/M4YlvDQ8BSIpYtPNkZIORY=;
        b=FOMO9TXifohbCh1z/kza1M18rwM9Q/p1Nc9sVH/NPD+T0QqSaZXZoOKz+E0QmIO0gV
         98bNxbKwACMjpVm44v6BIHvRVRkaVW1MDC7NE+M3gqviArQX5hvU6bRWQWUqp+af14Sc
         kg7td36lITBe1zGFhrYR/v5DPe3I3oOiANeODmDIYp3y5yL2e3OfF4AzIBaYZbTTy/Dc
         aD3cZQO96wioWd0HdVOhEUcG57IL7UzSX0ktQToA2Wmq4tHJ7Y7ZyKxZn7hH6bvjpmgh
         rqfDAQtv6jjVSFbVL24lMBOej48k3oTXDDdtOVEWIBou7hDIr2qcnT/F2IAyb9LtLal/
         QJzg==
X-Gm-Message-State: AHQUAuY8Qe4iQnmj4xzqMYV1a11Q/YYjBjSl9LBub7lBlhu66za7Gnpk
	WRQLW5VeX6Shytd74zoYw0dbKUtpEximehu9jZY86LSVo7c/3NHkkMuhyuB6MHHzWkycudb2dup
	zkqXYBQnQKnnEFmIGliLRsDDKeBR6EgfzEg1cMZgVRvFb8ZsnGCbvDV/WsZyNCfOZ6w==
X-Received: by 2002:a63:2744:: with SMTP id n65mr10835478pgn.65.1549478108895;
        Wed, 06 Feb 2019 10:35:08 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaM0yJ8Dc/0EqM/6AKIjCshSiQ86q2qeAzu9TzbllKaezLcU1Cv2aPiagCWndHEIqcS5vnK
X-Received: by 2002:a63:2744:: with SMTP id n65mr10835436pgn.65.1549478108142;
        Wed, 06 Feb 2019 10:35:08 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549478108; cv=none;
        d=google.com; s=arc-20160816;
        b=VvOPItYDKSkka/LFYYrqGPlGfoCCguwXxjviU6D5M5HqmtECBSsdxbJksqT+6Kawta
         iMe6poyVzAEwy3tVDKeWNiippPF9N8913xXrRAqzhLpAUAGQ7riqsvRjLhUI54IMgeET
         kLaO2MoYpgZ93nWXaK9j5O1NohLX1QHKi2kowpBwFScLCvhL9N+Hq68gvBMpkDMPMzne
         oUleM3+5G52l6ZvC/XI5FIGJcAdcKXAAe7VnFcvazjcCMRKwW1tlVZNfs7hQ/gka+d8M
         x16TDZH7AjKXaJp/howCfFklSRAJjrXbD3K+N9PYsa+9RKDWxGVi22pj9MDjo2EqcL4g
         lLcw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=qI29K96IrArheGtskdty/M4YlvDQ8BSIpYtPNkZIORY=;
        b=JCV0wVHzDdh/eRKyCpY7kVR5fyLOpic8Pt3+p1xBieWDdtJvYoCCEHLrUTDyxGZSLO
         6Le6t2gDGLqW1mUmONK9Y2jTHQLSb6QexPz78G69eXtxQq0/7Be1WUz6VllWBaSc7VtR
         fR7qogBp+R8nCkNbGXJgNUGA5KDaiJrWoi4+8JBGC6jC+0Q86Lo557rS8L8TXVxiaGGX
         NXEU12Pdt+oIT59c4zo6uD0xfdnxt4ROy/yg6CzVKXUbmC/1CKkXMSr+SB4hkm5m4Tsa
         d4UVq9GJ3d9v+OzzZr+wD5dkydcwAKxFWHFrveKnm6qDYoJHSmf/NKWbGfcqMUQBXZNu
         fNog==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=vANjs2HZ;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id v16si6453329plo.182.2019.02.06.10.35.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 06 Feb 2019 10:35:08 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=vANjs2HZ;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=qI29K96IrArheGtskdty/M4YlvDQ8BSIpYtPNkZIORY=; b=vANjs2HZBeSGsIJ3lVWi8DZVD
	FXcQzXRiaXnlbJbaNHMMz5rB1uCRmtDS05jhtlnMlprwaSI1fr/BZV6C57RLXpkYFPAONlFd1M7E+
	uC2CHtoQOb7aU3uYybJzUyhpS+S7KR9tW27Zg6wJBc1hGIOKddlyTEvjBIPvAtSYc1IJWPJVr3d/c
	5PeTnFCETxFmuk7KuhJTmmutnLRhKJtW+eIx7FpDZ/Ouh2Q0O2ML8CT5BmKJx5v4d5ETgFpkmJrzm
	ouOa+KlxEKtj5CBvL0Tc9uyen/ih/etkhU8eIZfoB15Hol1cNZhC89ThfrkdyVwGSF5bXT8Zgwyw4
	BAR3PItPw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1grS2K-0005xE-8p; Wed, 06 Feb 2019 18:35:04 +0000
Date: Wed, 6 Feb 2019 10:35:04 -0800
From: Matthew Wilcox <willy@infradead.org>
To: Doug Ledford <dledford@redhat.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>, Jan Kara <jack@suse.cz>,
	Ira Weiny <ira.weiny@intel.com>, lsf-pc@lists.linux-foundation.org,
	linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, John Hubbard <jhubbard@nvidia.com>,
	Jerome Glisse <jglisse@redhat.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	Michal Hocko <mhocko@kernel.org>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
Message-ID: <20190206183503.GO21860@bombadil.infradead.org>
References: <20190205175059.GB21617@iweiny-DESK2.sc.intel.com>
 <20190206095000.GA12006@quack2.suse.cz>
 <20190206173114.GB12227@ziepe.ca>
 <20190206175233.GN21860@bombadil.infradead.org>
 <47820c4d696aee41225854071ec73373a273fd4a.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <47820c4d696aee41225854071ec73373a273fd4a.camel@redhat.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 06, 2019 at 01:32:04PM -0500, Doug Ledford wrote:
> On Wed, 2019-02-06 at 09:52 -0800, Matthew Wilcox wrote:
> > On Wed, Feb 06, 2019 at 10:31:14AM -0700, Jason Gunthorpe wrote:
> > > On Wed, Feb 06, 2019 at 10:50:00AM +0100, Jan Kara wrote:
> > > 
> > > > MM/FS asks for lease to be revoked. The revoke handler agrees with the
> > > > other side on cancelling RDMA or whatever and drops the page pins. 
> > > 
> > > This takes a trip through userspace since the communication protocol
> > > is entirely managed in userspace.
> > > 
> > > Most existing communication protocols don't have a 'cancel operation'.
> > > 
> > > > Now I understand there can be HW / communication failures etc. in
> > > > which case the driver could either block waiting or make sure future
> > > > IO will fail and drop the pins. 
> > > 
> > > We can always rip things away from the userspace.. However..
> > > 
> > > > But under normal conditions there should be a way to revoke the
> > > > access. And if the HW/driver cannot support this, then don't let it
> > > > anywhere near DAX filesystem.
> > > 
> > > I think the general observation is that people who want to do DAX &
> > > RDMA want it to actually work, without data corruption, random process
> > > kills or random communication failures.
> > > 
> > > Really, few users would actually want to run in a system where revoke
> > > can be triggered.
> > > 
> > > So.. how can the FS/MM side provide a guarantee to the user that
> > > revoke won't happen under a certain system design?
> > 
> > Most of the cases we want revoke for are things like truncate().
> > Shouldn't happen with a sane system, but we're trying to avoid users
> > doing awful things like being able to DMA to pages that are now part of
> > a different file.
> 
> Why is the solution revoke then?  Is there something besides truncate
> that we have to worry about?  I ask because EBUSY is not currently
> listed as a return value of truncate, so extending the API to include
> EBUSY to mean "this file has pinned pages that can not be freed" is not
> (or should not be) totally out of the question.
> 
> Admittedly, I'm coming in late to this conversation, but did I miss the
> portion where that alternative was ruled out?

That's my preferred option too, but the preponderance of opinion leans
towards "We can't give people a way to make files un-truncatable".

