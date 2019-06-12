Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5894BC31E46
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 09:52:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2349A20866
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 09:52:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2349A20866
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 937236B0006; Wed, 12 Jun 2019 05:52:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8E8EC6B0007; Wed, 12 Jun 2019 05:52:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7FF0A6B0008; Wed, 12 Jun 2019 05:52:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 324296B0006
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 05:52:09 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id i44so25098809eda.3
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 02:52:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=yshU0Ks6zyYWz9UCiyn/wuj139FtV00nrtjLmYBPbBk=;
        b=SoZUWVo2RcKe8t3XTuf4akpdgbusxped5dHf8z7LRwJ4bP0+7R8y4xWTMWG7QVyqFo
         Z0wENC03YoCciBWka95nV5cegTgl9Ov1OHVbBHnrm7RF8J9n7PEidGNGiFyLPKYJYSYm
         U4jBKHCdxMQ0TKaKYDWIABZ4pHkadXNgnk2oYKU97Kb4Hpd5r/Y3HvH27oBXbAC8n73Y
         r60m+jORby3tGab2ZIZaPOCpJC9f/qYJ5KO5d3UARQ3ooT46e/IINmg+5qFcSzhWJ9LU
         iJxuaTB64bZyM3qHTTR4JvYwWMeGmWLTYumM7BTCBBbUsZmayJuWBOQED7ovZ/YsiwZ7
         egtg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: APjAAAUUViIlrzPser8iVhea6pwk0i4nRga1yerpDoViHsh/w7ErZLRg
	Tv2FYzYSOHQovGiOg/6BYimvQsKiLebfLwFBYO7G2MnGKudG76NmIFJHaWWGb6Ov5OOqqSkj0ZX
	dkrHzgb6sA7Q/bKM8kRh/W/LCUfTz62ZmvnywjTeIq53OcMxeZ8iMKFlxVUPNjPUZXg==
X-Received: by 2002:a17:906:d7ab:: with SMTP id pk11mr50469219ejb.216.1560333128724;
        Wed, 12 Jun 2019 02:52:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwZtlJOCLz74avp6Knu+gqWxZbq5Ef4zrNRQ1tQ9LzCcWGu3CszZbOi6heBQTVbmLVruYbv
X-Received: by 2002:a17:906:d7ab:: with SMTP id pk11mr50469168ejb.216.1560333127881;
        Wed, 12 Jun 2019 02:52:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560333127; cv=none;
        d=google.com; s=arc-20160816;
        b=hJqC0z4AeJRA6zgz/CSD2XyeFbTOsJw/LJFJTa7Xa1r+/3ysKoXHkWVL2s6Fnp+9cO
         RZhNCTamWi8g2I2gB4hqv55l0/6R2Hja8cfxpvlVCyBiTwAN9+vBIvO1jdOGwrscCJDo
         7cCNrrjcFxEwQxSXd54taktY5JlDCOtXc2YxoYFBsITt//CHxMTtQ9uGne5YGv9GLF4D
         pRJxcF0sl+RbHVQlR7GWkgk2lNrhQrBheo/AOOG5zODbRgy9B8oRfFFwkQZzx3TFQ9Pm
         gxHDkkXWRBi7dyXVtZTpUFHPCZpe8NO4luN5EJ32J4rIKnt69xaIwauX4TgVE+mN6KJe
         MVLA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=yshU0Ks6zyYWz9UCiyn/wuj139FtV00nrtjLmYBPbBk=;
        b=YKL2CBhERY1aK7M8k5z4NSt7zYInRBjQp/vuPZFshTJeFtRncpeLnAAH8ka1gmB6/H
         ZYZWtDCVa8q3GvFGPWJkj1jcDSMMBvgnUJiyRv/wH/GVQISpMydCl++ghXg4kcmwz+Jh
         +XdyGqhPJIu/JBz6Xhf3zFoVnIGTBuC/x7PKgTQgJmXu2mOPt7oCXd+7uBHbaDfJy6ZB
         oDRSLFyaB+E8XXEsWh2icQDcQaXmQD+H+Ut0/Dl/djpQvOihKPkH/A0Wdes1mCMYJXcI
         A4VcUbLAMer3/begMf6ot23rS5hayMgz3dWDZybkAGPQMaaEUIvM8j4c0JD9wHvsjwOu
         SlhA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o3si6653236ejc.57.2019.06.12.02.52.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 02:52:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id ECAA6AF52;
	Wed, 12 Jun 2019 09:52:06 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id 89C291E4328; Wed, 12 Jun 2019 11:46:34 +0200 (CEST)
Date: Wed, 12 Jun 2019 11:46:34 +0200
From: Jan Kara <jack@suse.cz>
To: Ira Weiny <ira.weiny@intel.com>
Cc: Jeff Layton <jlayton@kernel.org>,
	Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>,
	Theodore Ts'o <tytso@mit.edu>, Dave Chinner <david@fromorbit.com>,
	Matthew Wilcox <willy@infradead.org>, linux-xfs@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	John Hubbard <jhubbard@nvidia.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-nvdimm@lists.01.org, linux-ext4@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH RFC 02/10] fs/locks: Export F_LAYOUT lease to user space
Message-ID: <20190612094634.GA14578@quack2.suse.cz>
References: <20190606014544.8339-1-ira.weiny@intel.com>
 <20190606014544.8339-3-ira.weiny@intel.com>
 <4e5eb31a41b91a28fbc83c65195a2c75a59cfa24.camel@kernel.org>
 <20190611213812.GC14336@iweiny-DESK2.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190611213812.GC14336@iweiny-DESK2.sc.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 11-06-19 14:38:13, Ira Weiny wrote:
> On Sun, Jun 09, 2019 at 09:00:24AM -0400, Jeff Layton wrote:
> > On Wed, 2019-06-05 at 18:45 -0700, ira.weiny@intel.com wrote:
> > > From: Ira Weiny <ira.weiny@intel.com>
> > > 
> > > GUP longterm pins of non-pagecache file system pages (eg FS DAX) are
> > > currently disallowed because they are unsafe.
> > > 
> > > The danger for pinning these pages comes from the fact that hole punch
> > > and/or truncate of those files results in the pages being mapped and
> > > pinned by a user space process while DAX has potentially allocated those
> > > pages to other processes.
> > > 
> > > Most (All) users who are mapping FS DAX pages for long term pin purposes
> > > (such as RDMA) are not going to want to deallocate these pages while
> > > those pages are in use.  To do so would mean the application would lose
> > > data.  So the use case for allowing truncate operations of such pages
> > > is limited.
> > > 
> > > However, the kernel must protect itself and users from potential
> > > mistakes and/or malicious user space code.  Rather than disabling long
> > > term pins as is done now.   Allow for users who know they are going to
> > > be pinning this memory to alert the file system of this intention.
> > > Furthermore, allow users to be alerted such that they can react if a
> > > truncate operation occurs for some reason.
> > > 
> > > Example user space pseudocode for a user using RDMA and wanting to allow
> > > a truncate would look like this:
> > > 
> > > lease_break_sigio_handler() {
> > > ...
> > > 	if (sigio.fd == rdma_fd) {
> > > 		complete_rdma_operations(...);
> > > 		ibv_dereg_mr(mr);
> > > 		close(rdma_fd);
> > > 		fcntl(rdma_fd, F_SETLEASE, F_UNLCK);
> > > 	}
> > > }
> > > 
> > > setup_rdma_to_dax_file() {
> > > ...
> > > 	rdma_fd = open(...)
> > > 	fcntl(rdma_fd, F_SETLEASE, F_LAYOUT);
> > 
> > I'm not crazy about this interface. F_LAYOUT doesn't seem to be in the
> > same category as F_RDLCK/F_WRLCK/F_UNLCK.
> > 
> > Maybe instead of F_SETLEASE, this should use new
> > F_SETLAYOUT/F_GETLAYOUT cmd values? There is nothing that would prevent
> > you from setting both a lease and a layout on a file, and indeed knfsd
> > can set both.
> > 
> > This interface seems to conflate the two.
> 
> I've been feeling the same way.  This is why I was leaning toward a new lease
> type.  I called it "F_LONGTERM" but the name is not important.
> 
> I think the concept of adding "exclusive" to the layout lease can fix this
> because the NFS lease is non-exclusive where the user space one (for the
> purpose of GUP pinning) would need to be.
> 
> FWIW I have not worked out exactly what this new "exclusive" code will look
> like.  Jan said:
> 
> 	"There actually is support for locks that are not broken after given
> 	timeout so there shouldn't be too many changes need."
> 
> But I'm not seeing that for Lease code.  So I'm working on something for the
> lease code now.

Yeah, sorry for misleading you. Somehow I thought that if lease_break_time
== 0, we will wait indefinitely but when checking the code again, that
doesn't seem to be the case.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

