Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B23CCC10F03
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 21:23:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6A2942175B
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 21:23:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6A2942175B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D0B146B0005; Tue, 19 Mar 2019 17:23:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C920D6B0006; Tue, 19 Mar 2019 17:23:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B336A6B0007; Tue, 19 Mar 2019 17:23:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 712016B0005
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 17:23:54 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id o67so205527pfa.20
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 14:23:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=lMT8Mu84Fop6jiESGOrwJHIxx685RNT4YA1Ft7JSxZA=;
        b=svY0doK+jZu5CoPQTIobTV8LwO+OJi9bpVFGtuMJhget87ajdeZnpTMWyzTra1+1QB
         w3DTQsyHkMoENX2hT1OsE7deevkWA5m4TOa8rSaF2Nio54CFtVNyGASBRFhGJM3s0XoF
         wkLDstO/OQSj1YRaTaRbRkdUGynU54f6EElbhtUxZ/XZsirvi1awFRxNm+oOfAllwZmu
         3Yl9mcFlfOV9/9GawpVDhYR/7ZC70ihrTM6HEH8nzL/tSivIxeaGvUs3StdoiQhcUKIt
         ye+pcDIwAx8ild2MxRe59ci87dtgiSYAHAp858RtmurgOgmCFSnsm71tqTegOErbeP+F
         Si4A==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 150.101.137.141 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAU1z6FXNCzBfn7IEJ6ekyMW0qZs3mRjF/7rcM3rGylHjmHun4bf
	4eb5zbhdY8iAuBdoxA1h/1SY2QglqiHJcaTU7AxncNTE99+G8qmgrO1Q5pE/F6Qg6eWukTijV6b
	Dsa5EuvfOlww1usrRqLrotLxOJD4S8Qqga6icRj/LQBCUdIMwic0TfCtDOtFZReU=
X-Received: by 2002:a63:5515:: with SMTP id j21mr3905481pgb.244.1553030634026;
        Tue, 19 Mar 2019 14:23:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwgJOetJ+36qRa5zFy1wDpo8iKtXmSnqtxltlL8Gp6MgjJVz2iVlFpG1D1EKi84UL7KuIsc
X-Received: by 2002:a63:5515:: with SMTP id j21mr3905419pgb.244.1553030632749;
        Tue, 19 Mar 2019 14:23:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553030632; cv=none;
        d=google.com; s=arc-20160816;
        b=ZzhTIx+7RH4zoA4y+aTsg9rT+srXZZSEodbFZkEYqC5br6UOxq7p2Ed7uOscujT21C
         BgV3ae8QAgduXY69y++dYYYrC5s2q+JXjMI9ScP48xd9kEYmjxYYSj1uFteOdmbSbpQx
         +ZNaCMcUPTeVA2OCRDcH7Y8SopV0GEl4+WexNSiFOUfdb4b+fZJkaTOXYBkzJsMnnFEK
         Y89p8UQbTYQgqynjpO+6cCP7/JkdEbrCS+gO8TvJD3KzwD8hFfr40FTmyvuMAHi4Y7Oq
         I3NUn6n//X6viIULXzKFPxjGd1ud18LAKSlLkA7Gz8bylDr4eqjny9MVa3ei93F7lP7a
         AgGg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=lMT8Mu84Fop6jiESGOrwJHIxx685RNT4YA1Ft7JSxZA=;
        b=IebCUcWsU1Fe1JG2w6jW3cEhBUuG/yHDr4Bc2CQ4ThkKXnO6sKnWiZH9fBuxxvzP9G
         9a4/wwjvaBXwjmN7AhFJ2QcBHEQ7lTveKEsdsDVQxEWsc9cOIJe5p6iNifvNYBre9KhF
         in3aJWOy794HgYa5gaI8Rw4uxc237nJv0wnKJKEf3wg9pQQBqAVLYxL2vyTNpUuU45+p
         oHctozsMi0fHBZyLAyf4SezDvxYDkqNYAG+qnzx6eBhXtK778peHdgKYFdUa9wvtDSUy
         aqX7KkKo9D5xYQ3pRihlJaQZYAAh6QAUI5BamIgKbuLe/KicQD94hMc+F29qp3gHcvyY
         ukIQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 150.101.137.141 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ipmail03.adl2.internode.on.net (ipmail03.adl2.internode.on.net. [150.101.137.141])
        by mx.google.com with ESMTP id q20si106277plr.136.2019.03.19.14.23.51
        for <linux-mm@kvack.org>;
        Tue, 19 Mar 2019 14:23:52 -0700 (PDT)
Received-SPF: neutral (google.com: 150.101.137.141 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=150.101.137.141;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 150.101.137.141 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ppp59-167-129-252.static.internode.on.net (HELO dastard) ([59.167.129.252])
  by ipmail03.adl2.internode.on.net with ESMTP; 20 Mar 2019 07:53:49 +1030
Received: from dave by dastard with local (Exim 4.80)
	(envelope-from <david@fromorbit.com>)
	id 1h6MD4-0003Pg-M8; Wed, 20 Mar 2019 08:23:46 +1100
Date: Wed, 20 Mar 2019 08:23:46 +1100
From: Dave Chinner <david@fromorbit.com>
To: Jerome Glisse <jglisse@redhat.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, john.hubbard@gmail.com,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	Al Viro <viro@zeniv.linux.org.uk>,
	Christian Benvenuti <benve@cisco.com>,
	Christoph Hellwig <hch@infradead.org>,
	Christopher Lameter <cl@linux.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Doug Ledford <dledford@redhat.com>, Ira Weiny <ira.weiny@intel.com>,
	Jan Kara <jack@suse.cz>, Jason Gunthorpe <jgg@ziepe.ca>,
	Matthew Wilcox <willy@infradead.org>,
	Michal Hocko <mhocko@kernel.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Ralph Campbell <rcampbell@nvidia.com>, Tom Talpey <tom@talpey.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>,
	Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH v4 1/1] mm: introduce put_user_page*(), placeholder
 versions
Message-ID: <20190319212346.GA26298@dastard>
References: <20190308213633.28978-1-jhubbard@nvidia.com>
 <20190308213633.28978-2-jhubbard@nvidia.com>
 <20190319120417.yzormwjhaeuu7jpp@kshutemo-mobl1>
 <20190319134724.GB3437@redhat.com>
 <20190319141416.GA3879@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190319141416.GA3879@redhat.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 19, 2019 at 10:14:16AM -0400, Jerome Glisse wrote:
> On Tue, Mar 19, 2019 at 09:47:24AM -0400, Jerome Glisse wrote:
> > On Tue, Mar 19, 2019 at 03:04:17PM +0300, Kirill A. Shutemov wrote:
> > > On Fri, Mar 08, 2019 at 01:36:33PM -0800, john.hubbard@gmail.com wrote:
> > > > From: John Hubbard <jhubbard@nvidia.com>
> > 
> > [...]
> > 
> > > > diff --git a/mm/gup.c b/mm/gup.c
> > > > index f84e22685aaa..37085b8163b1 100644
> > > > --- a/mm/gup.c
> > > > +++ b/mm/gup.c
> > > > @@ -28,6 +28,88 @@ struct follow_page_context {
> > > >  	unsigned int page_mask;
> > > >  };
> > > >  
> > > > +typedef int (*set_dirty_func_t)(struct page *page);
> > > > +
> > > > +static void __put_user_pages_dirty(struct page **pages,
> > > > +				   unsigned long npages,
> > > > +				   set_dirty_func_t sdf)
> > > > +{
> > > > +	unsigned long index;
> > > > +
> > > > +	for (index = 0; index < npages; index++) {
> > > > +		struct page *page = compound_head(pages[index]);
> > > > +
> > > > +		if (!PageDirty(page))
> > > > +			sdf(page);
> > > 
> > > How is this safe? What prevents the page to be cleared under you?
> > > 
> > > If it's safe to race clear_page_dirty*() it has to be stated explicitly
> > > with a reason why. It's not very clear to me as it is.
> > 
> > The PageDirty() optimization above is fine to race with clear the
> > page flag as it means it is racing after a page_mkclean() and the
> > GUP user is done with the page so page is about to be write back
> > ie if (!PageDirty(page)) see the page as dirty and skip the sdf()
> > call while a split second after TestClearPageDirty() happens then
> > it means the racing clear is about to write back the page so all
> > is fine (the page was dirty and it is being clear for write back).
> > 
> > If it does call the sdf() while racing with write back then we
> > just redirtied the page just like clear_page_dirty_for_io() would
> > do if page_mkclean() failed so nothing harmful will come of that
> > neither. Page stays dirty despite write back it just means that
> > the page might be write back twice in a row.
> 
> Forgot to mention one thing, we had a discussion with Andrea and Jan
> about set_page_dirty() and Andrea had the good idea of maybe doing
> the set_page_dirty() at GUP time (when GUP with write) not when the
> GUP user calls put_page(). We can do that by setting the dirty bit
> in the pte for instance. They are few bonus of doing things that way:
>     - amortize the cost of calling set_page_dirty() (ie one call for
>       GUP and page_mkclean()
>     - it is always safe to do so at GUP time (ie the pte has write
>       permission and thus the page is in correct state)
>     - safe from truncate race
>     - no need to ever lock the page

I seem to have missed this conversation, so please excuse me for
asking a stupid question: if it's a file backed page, what prevents
background writeback from cleaning the dirty page ~30s into a long
term pin? i.e. I don't see anything in this proposal that prevents
the page from being cleaned by writeback and putting us straight
back into the situation where a long term RDMA is writing to a clean
page....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

