Return-Path: <SRS0=ikTF=QP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A6835C282CC
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 11:10:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6C9D4218D9
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 11:10:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6C9D4218D9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 038E48E008C; Fri,  8 Feb 2019 06:10:33 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F02598E008A; Fri,  8 Feb 2019 06:10:32 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DA4118E008C; Fri,  8 Feb 2019 06:10:32 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7A38E8E008A
	for <linux-mm@kvack.org>; Fri,  8 Feb 2019 06:10:32 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id v26so1397887eds.17
        for <linux-mm@kvack.org>; Fri, 08 Feb 2019 03:10:32 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=/jy4VguCfapXyCYW0zVi/XiLIVpk/VCsqtWDzl2/J6k=;
        b=I/itLDS3wjaUZlqC+QR8i8E3w+0HCRXakSTlKSj5iDk7FphcCUzFFTc3W8O6zbsLPh
         UqGIkjO3WifmTVK1VWDqiNQgqy8HB4dy5mOGmOgSoFs8hnDzEaD+qhYBEOjnhM36J0gH
         LLk2nnVX3lDFO+s3F8ISbiG/rS6F7bK846d58U7Yqpl4T/0wp2ixNQ1ggDusu2XSvTj3
         5sa7ff/KTdBvxuCS1CYTTzmLZ1+6KzqtK89d0A72y4WvuRNFTf4b7mCshwFl5fKegfK3
         jJkGG7RBB9WQf/lYogrM6ru25H1yEVym/twdl1AUIFnKHPE39kuqgj6cg15AlfmtwMwF
         zE9w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: AHQUAuYZ3EKIzGXvz0wwR6OrxUyY4hJvMxzOTbDS7H00N20an1h5xKUj
	+oaig2/dDLIwy3G3yyIRhUkMebmj5ODyr9XOvS3ysDs0OiqU7Z/LL++SuhsnWfg5ZmLmINCst8y
	DiRqdfn/ZewAG5KQapilpIVWuKwMwiSSpya4mQp2HP3oJl/JmeWiwWg0gDnGnUBX3aQ==
X-Received: by 2002:a17:906:7805:: with SMTP id u5-v6mr15751998ejm.213.1549624232052;
        Fri, 08 Feb 2019 03:10:32 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYbiTrYEeGBftmmZQhe9ilZ4pw8jwzK5auFxxojf/IjZWlPCMOaq4bdyqGxC0MfFJlpIhcQ
X-Received: by 2002:a17:906:7805:: with SMTP id u5-v6mr15751916ejm.213.1549624230815;
        Fri, 08 Feb 2019 03:10:30 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549624230; cv=none;
        d=google.com; s=arc-20160816;
        b=1K6tZwNZ/d4K6++JklaQTO2t47a4acYwoYfrt2WFqDZ/ZWMTvo6qiH/XgWsaoxQm1i
         JxDWJ/2ST+EkeIIWKR2WADFNKZ86o2k89wNrkNksBY6Xf2U8vrdAQ8OlHNicSHm4FHHn
         motu9jYU0h0XDalBArbTyGBw+aq3EGPjOQ44/FO3spz7k0/z2DNjRxOKxOQ6toBHBnNS
         v36MJP1Rsz7DVmLZV9cOlM17wCPXDV3atvJMzS8AwLAXunn5AOVKppbH5VInagS81Iqz
         /PaTd8ImLL3fArMdlfyGW5wt2UjPon7gnmCuWOucFj3QUwLk4JuT8iaxefu46qlEaPRp
         ZU1A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=/jy4VguCfapXyCYW0zVi/XiLIVpk/VCsqtWDzl2/J6k=;
        b=qMBI33TQLAJSYcBMC7t2OWb/RhpsUXuWlua1kXs2fOZypMt0TXa6AHLMTchJ+1g1y2
         B3jp9OWbOa1ADbZ5EXm7umuIiuIN8oLJ0IwDYs12loaSk9iyPN6b8Vw+NChkXKos6zZD
         MEKRb22HfKlUewBABKZG6OHSuCpDzqKW6c9EjPP3g0xbYuJ4qICUVRjp6H7zIfj3K0HX
         0+hG8nCQTxX6AjB/DM72Ibe45yBGQz9Zq83uPZYpneUJifi4Id1qW9qTVO9m7JQT+MWq
         HjBZA+HlH+Zt1p9LNoholeecuo78A6ghguJJOPzGejJo7VyUROh/oMINurVdvIwLc5Xm
         Th6w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l24si96709edr.135.2019.02.08.03.10.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Feb 2019 03:10:30 -0800 (PST)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id BF4C5AE65;
	Fri,  8 Feb 2019 11:10:29 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id C875D1E3DB8; Fri,  8 Feb 2019 12:10:28 +0100 (CET)
Date: Fri, 8 Feb 2019 12:10:28 +0100
From: Jan Kara <jack@suse.cz>
To: Dave Chinner <david@fromorbit.com>
Cc: Christopher Lameter <cl@linux.com>, Doug Ledford <dledford@redhat.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>,
	Ira Weiny <ira.weiny@intel.com>, lsf-pc@lists.linux-foundation.org,
	linux-rdma <linux-rdma@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	John Hubbard <jhubbard@nvidia.com>,
	Jerome Glisse <jglisse@redhat.com>,
	Michal Hocko <mhocko@kernel.org>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
Message-ID: <20190208111028.GD6353@quack2.suse.cz>
References: <20190206175233.GN21860@bombadil.infradead.org>
 <47820c4d696aee41225854071ec73373a273fd4a.camel@redhat.com>
 <01000168c43d594c-7979fcf8-b9c1-4bda-b29a-500efe001d66-000000@email.amazonses.com>
 <20190206210356.GZ6173@dastard>
 <20190206220828.GJ12227@ziepe.ca>
 <0c868bc615a60c44d618fb0183fcbe0c418c7c83.camel@redhat.com>
 <CAPcyv4hqya1iKCfHJRXQJRD4qXZa3VjkoKGw6tEvtWNkKVbP+A@mail.gmail.com>
 <bfe0fdd5400d41d223d8d30142f56a9c8efc033d.camel@redhat.com>
 <01000168c8e2de6b-9ab820ed-38ad-469c-b210-60fcff8ea81c-000000@email.amazonses.com>
 <20190208044302.GA20493@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190208044302.GA20493@dastard>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 08-02-19 15:43:02, Dave Chinner wrote:
> On Thu, Feb 07, 2019 at 04:55:37PM +0000, Christopher Lameter wrote:
> > One approach that may be a clean way to solve this:
> > 3. Filesystems that allow bypass of the page cache (like XFS / DAX) will
> >    provide the virtual mapping when the PIN is done and DO NO OPERATIONS
> >    on the longterm pinned range until the long term pin is removed.
> 
> So, ummm, how do we do block allocation then, which is done on
> demand during writes?
> 
> IOWs, this requires the application to set up the file in the
> correct state for the filesystem to lock it down so somebody else
> can write to it.  That means the file can't be sparse, it can't be
> preallocated (i.e. can't contain unwritten extents), it must have zeroes
> written to it's full size before being shared because otherwise it
> exposes stale data to the remote client (secure sites are going to
> love that!), they can't be extended, etc.
> 
> IOWs, once the file is prepped and leased out for RDMA, it becomes
> an immutable for the purposes of local access.
> 
> Which, essentially we can already do. Prep the file, map it
> read/write, mark it immutable, then pin it via the longterm gup
> interface which can do the necessary checks.

Hum, and what will you do if the immutable file that is target for RDMA
will be a source of reflink? That seems to be currently allowed for
immutable files but RDMA store would be effectively corrupting the data of
the target inode. But we could treat it similarly as swapfiles - those also
have to deal with writes to blocks beyond filesystem control. In fact the
similarity seems to be quite large there. What do you think?

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

