Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4A75AC4151A
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 17:52:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 07A152075C
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 17:52:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Mirs8uEt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 07A152075C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9A25B8E00DE; Wed,  6 Feb 2019 12:52:38 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 950DF8E00D1; Wed,  6 Feb 2019 12:52:38 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7F36E8E00DE; Wed,  6 Feb 2019 12:52:38 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 371388E00D1
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 12:52:38 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id q20so5432275pls.4
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 09:52:38 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=/JM8xhN7e4ll6dIOfHOJWjqFYstXE/mHbTZT2vaTgc4=;
        b=mzQzB72tobAvth66qJ4fI902R5A8cQwJEo0f6PKrGipGNjIKChzliMDTwtSlZED+/t
         SNrifC9l/5G9B6066tidKKFUgFlLPVx5VI3jUE3i8k52Fc4qNJYQWAfsSap9PQ2Ve6YB
         mbBYipmJHAynyqsA81y4K6/8aihI9t7pYsoHgcAvGLuzRB4DiRDaCIA4JRmzdVUilTY2
         S1FSFpMvN+GKGJdwQwnfr+c5i1UEwmWbV6pIW8lceMC3DV5bj7LHYdFcDlyFfZxNkZL7
         x5QSVgF5ce1BW6u+eb1ucbPdUh2Nxf/cCz+iV3fRO+pFisn/GDngwDRaYPscjTYS9A5L
         r62Q==
X-Gm-Message-State: AHQUAubtZVfI3iyGZJZvDL8FPegApn/N/VgywBHaKokq/VBYhiK3yTp+
	D3sgEvknQTSCYdOOAXPpnnBKnYA0VZRvFX5sDo9S4tIJzPrutfBpeJaTsj5qvulk8YUwTd9yLQI
	NqqJkJrHDifPI+u7/EObFPVOqiTsa8OyNU9rgy8Wq1Mmh0Ats3A5QSU0n1uxEmIpiYw==
X-Received: by 2002:a17:902:9305:: with SMTP id bc5mr11842869plb.86.1549475557888;
        Wed, 06 Feb 2019 09:52:37 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYVmfzCgZ+pKm4oUgBUIcv/XsJUcrBVTCheFjYPs4ksEIv/UbelhC0yQBZ2XpoPrZSJgL4w
X-Received: by 2002:a17:902:9305:: with SMTP id bc5mr11842799plb.86.1549475557003;
        Wed, 06 Feb 2019 09:52:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549475557; cv=none;
        d=google.com; s=arc-20160816;
        b=Ace99sEYUF2Qr7N05TIvEkTwqw6EHTY7JX6rjftKBwB+Wo4Ya1osGWk1LrFIdF+0I9
         qtsY7PHqjnEdAxwJvOF/DxQkij8X21Sz/Ox7UlcshgFFQmZse6i2BXgWZ4Q+OcloEPpX
         m9f+7P92KCdAuP2A6E2uzg60+2XlFdwCeC7+ldXrFWXIznBxju1IZzZS4JFpQT0t/pJE
         aDti5kToZl9cdBL2leND5hwBAfdb6szehdLNzL+Pvn5ftIXYqYcMVlNfeBSk+2VIPO/N
         9WVz2kcmNYBISrCWAhX9Vfe0HwsHKb1OgCUyEuJYYhU+u60NicsgAYmIYrfwhYMIwt+t
         hxdA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=/JM8xhN7e4ll6dIOfHOJWjqFYstXE/mHbTZT2vaTgc4=;
        b=mWHwsDFbPKPkoD2asztteetWGG8v+4+gwtkemrFT7/d52xBXgyLhO+S4lPYrfhFsHe
         E7A3ud+zbOuyeud/qt1S9qMii5sjpobylc2ZOLpqe9bGfPyMcPbmmd/bjyAlngHCa5oz
         xOnbAw/BcYc3tO0t/FwtLoZWhJwmOWbPuI7kpsLLmIHlMucKCw3j88N+vgzBejPQFZ3b
         +dXxQLuULsfv9XjjrnBdJl5l+2dzJWZg19RGi8gMrpxkK1wl74c9+K5ZntdBd/D/+HUP
         A3GuYg/gBSzEj8FQKeZYkQPmEB6rbX0rghA60sfj/ip4AWYjCJWBs7TguSGIqY/lAsri
         2TOg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Mirs8uEt;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a3si6333766pga.297.2019.02.06.09.52.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 06 Feb 2019 09:52:36 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Mirs8uEt;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=/JM8xhN7e4ll6dIOfHOJWjqFYstXE/mHbTZT2vaTgc4=; b=Mirs8uEthgr5XYNVmirKwundg
	sWy+gu+BS7j+QeM5lRkc2WA/dD5BCWVfh/p5kxzdlLmzzwS+7cmvM0HiMcRgjjlRrPa7gjloa5ZDy
	+6575c/+leWN4hTJAWmMWr5L6+0hOtK0imZ0eTSUttMbVwEFR982PjYdZvNh2irh8Igamks3vDvTS
	Mx/qNCr4b7lmzCj2TNsPQOtUzHuny1h98nsDxCTYZo0T43f9aap7x6O/bmoAshx7/RgHzhxNlDwdv
	isiTF3tSnXWK9uCBLzt4D5ilHRcg+7+W230mHja0ns4B4BQ08k34gVaC5n+e7ik6sYqNIto+SNBA0
	yBmS7qivQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1grRNB-00028m-9j; Wed, 06 Feb 2019 17:52:33 +0000
Date: Wed, 6 Feb 2019 09:52:33 -0800
From: Matthew Wilcox <willy@infradead.org>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Jan Kara <jack@suse.cz>, Ira Weiny <ira.weiny@intel.com>,
	lsf-pc@lists.linux-foundation.org, linux-rdma@vger.kernel.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>,
	Jerome Glisse <jglisse@redhat.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	Doug Ledford <dledford@redhat.com>,
	Michal Hocko <mhocko@kernel.org>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
Message-ID: <20190206175233.GN21860@bombadil.infradead.org>
References: <20190205175059.GB21617@iweiny-DESK2.sc.intel.com>
 <20190206095000.GA12006@quack2.suse.cz>
 <20190206173114.GB12227@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190206173114.GB12227@ziepe.ca>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 06, 2019 at 10:31:14AM -0700, Jason Gunthorpe wrote:
> On Wed, Feb 06, 2019 at 10:50:00AM +0100, Jan Kara wrote:
> 
> > MM/FS asks for lease to be revoked. The revoke handler agrees with the
> > other side on cancelling RDMA or whatever and drops the page pins. 
> 
> This takes a trip through userspace since the communication protocol
> is entirely managed in userspace.
> 
> Most existing communication protocols don't have a 'cancel operation'.
> 
> > Now I understand there can be HW / communication failures etc. in
> > which case the driver could either block waiting or make sure future
> > IO will fail and drop the pins. 
> 
> We can always rip things away from the userspace.. However..
> 
> > But under normal conditions there should be a way to revoke the
> > access. And if the HW/driver cannot support this, then don't let it
> > anywhere near DAX filesystem.
> 
> I think the general observation is that people who want to do DAX &
> RDMA want it to actually work, without data corruption, random process
> kills or random communication failures.
> 
> Really, few users would actually want to run in a system where revoke
> can be triggered.
> 
> So.. how can the FS/MM side provide a guarantee to the user that
> revoke won't happen under a certain system design?

Most of the cases we want revoke for are things like truncate().
Shouldn't happen with a sane system, but we're trying to avoid users
doing awful things like being able to DMA to pages that are now part of
a different file.

