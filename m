Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AE5FFC43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 23:57:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 651E3217F4
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 23:57:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 651E3217F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F090C6B0003; Tue, 19 Mar 2019 19:57:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E68E96B0006; Tue, 19 Mar 2019 19:57:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CE3836B0007; Tue, 19 Mar 2019 19:57:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 877686B0003
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 19:57:58 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id f1so727625pgv.12
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 16:57:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=sRQ41Mh0o0QUIvWAPG1HS8cc+I3ZQ4LgOEFU3XDcYys=;
        b=GRTja2wUA6twlpRfkgQh72pWviO7uu8I7rEiyVd3iL58ije/GSKca4UwP2MERRySqS
         ECYNG4o2O7RK+LwJZSaTYuPcK7p+PrH/VasTfPXH7wAU+Hcw+1eEUnYU55PAnKl9u1db
         3GNeCHH2TDwbjlKOfPHjjti9th2u0nvlPPHbJ/XLI8KbpbTJvqFR31xbW6oxWtu09++T
         c1yFISD+ohhQfxPrufA/+XXYN0XBGks+jHldFwtiV1PekTl81MKxD20MJHYkDNnm0qBM
         pJ4ZYpDTxWQYR2W1a35zZHHjbS1C8Yw8qiQqywucYdNsCy0IEEyzsRpirUbYzoTDd7rs
         9v6g==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 150.101.137.145 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAUCdhIHz/ZKBjgd11t1yslVocRJp7VUfl5SJuPwbMbidkUrCtSp
	EC6GsnWa4mvjATaYjbmu3EU8Rbob7A7xlTnI0Bu/EH9yeOhUdWs+qi3FZiLU/6gp+/Zmm3e9/ej
	D2buSzfChG0tSIDpjfWoiwISBOoG5fm6M+coZEbv1lT7u1e8Wfkdjqr4vjW3Im0U=
X-Received: by 2002:a65:64d5:: with SMTP id t21mr4717313pgv.266.1553039878212;
        Tue, 19 Mar 2019 16:57:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxCXJqZNzxk6ACjnGlXcQlcJKuTAYZPuqdrIDZhp9RfrGokdkMwCi8EbMTbOIykcSCO7xOL
X-Received: by 2002:a65:64d5:: with SMTP id t21mr4717268pgv.266.1553039876978;
        Tue, 19 Mar 2019 16:57:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553039876; cv=none;
        d=google.com; s=arc-20160816;
        b=X0kuOt+xmrGCK22Ax2LfRGNNeq5hOGSwsPlXaKWn7qLscLGyp6fR8ZpVlSInacSwJb
         bYG6f4K+c+xgo4Fgfp14Q2mYuW2XiOmc3cduHGHixccpvkKndiQqO1/q3E9Om8lSbeW1
         DJO3E9Auo3i6SNSGbJgEHW4zQPCMQATucrDIae4msFepE0Q7t6UHRbZSdHtamIICKeid
         N0tyU3jJGATFFy7JUrIB/dLMDdun5nO3jlKFLVhd4owG07Yvh8wDRGHScAixLdT44JF5
         mNsXAsKhGb95WJd9wjMVhvDz+PL88BzI5fEH0KDB1hNtL2rtlxPWGmF4uFqtzbl5WUXv
         dK2Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=sRQ41Mh0o0QUIvWAPG1HS8cc+I3ZQ4LgOEFU3XDcYys=;
        b=Run4c1N4P23UCQzRvkO3MS/zmkOkGyv7gofIZQGur7LHQ9v/78IlDXhzIKp2M9wLYA
         6rmbiaNk0ltXForbQ1ranZmMUt8JIbJZh2fUfTtNdttOHhwvfe1OKElOhRlKA6LXCcbu
         ILXmNoU/9dgH9x1d4hr9YTNQrkHRyNLzGFo6gj2UQ2Cr4hTTwlnpbh6AkgOOftDJJFiZ
         7geZYzVmF7VHEu1IzbUGc9SK3C/bA0K1iS38mBpjNFMkR6gKOX9FTf5an6bqzpyEMQI5
         y/W2SMV9ZZz6XWV14evNLGyBMoGYCJtL5nvIAj+oBq+psqvk2GtjtRHDYHfJGInJblIE
         +0KA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 150.101.137.145 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id x22si373877plr.111.2019.03.19.16.57.55
        for <linux-mm@kvack.org>;
        Tue, 19 Mar 2019 16:57:56 -0700 (PDT)
Received-SPF: neutral (google.com: 150.101.137.145 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=150.101.137.145;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 150.101.137.145 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ppp59-167-129-252.static.internode.on.net (HELO dastard) ([59.167.129.252])
  by ipmail06.adl6.internode.on.net with ESMTP; 20 Mar 2019 10:27:53 +1030
Received: from dave by dastard with local (Exim 4.80)
	(envelope-from <david@fromorbit.com>)
	id 1h6OcC-0003YB-LF; Wed, 20 Mar 2019 10:57:52 +1100
Date: Wed, 20 Mar 2019 10:57:52 +1100
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
Message-ID: <20190319235752.GB26298@dastard>
References: <20190308213633.28978-1-jhubbard@nvidia.com>
 <20190308213633.28978-2-jhubbard@nvidia.com>
 <20190319120417.yzormwjhaeuu7jpp@kshutemo-mobl1>
 <20190319134724.GB3437@redhat.com>
 <20190319141416.GA3879@redhat.com>
 <20190319212346.GA26298@dastard>
 <20190319220654.GC3096@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190319220654.GC3096@redhat.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 19, 2019 at 06:06:55PM -0400, Jerome Glisse wrote:
> On Wed, Mar 20, 2019 at 08:23:46AM +1100, Dave Chinner wrote:
> > On Tue, Mar 19, 2019 at 10:14:16AM -0400, Jerome Glisse wrote:
> > > On Tue, Mar 19, 2019 at 09:47:24AM -0400, Jerome Glisse wrote:
> > > > On Tue, Mar 19, 2019 at 03:04:17PM +0300, Kirill A. Shutemov wrote:
> > > > > On Fri, Mar 08, 2019 at 01:36:33PM -0800, john.hubbard@gmail.com wrote:
> > > > > > From: John Hubbard <jhubbard@nvidia.com>
> > > > 
> > > > [...]
> > > > 
> > > > > > diff --git a/mm/gup.c b/mm/gup.c
> > > > > > index f84e22685aaa..37085b8163b1 100644
> > > > > > --- a/mm/gup.c
> > > > > > +++ b/mm/gup.c
> > > > > > @@ -28,6 +28,88 @@ struct follow_page_context {
> > > > > >  	unsigned int page_mask;
> > > > > >  };
> > > > > >  
> > > > > > +typedef int (*set_dirty_func_t)(struct page *page);
> > > > > > +
> > > > > > +static void __put_user_pages_dirty(struct page **pages,
> > > > > > +				   unsigned long npages,
> > > > > > +				   set_dirty_func_t sdf)
> > > > > > +{
> > > > > > +	unsigned long index;
> > > > > > +
> > > > > > +	for (index = 0; index < npages; index++) {
> > > > > > +		struct page *page = compound_head(pages[index]);
> > > > > > +
> > > > > > +		if (!PageDirty(page))
> > > > > > +			sdf(page);
> > > > > 
> > > > > How is this safe? What prevents the page to be cleared under you?
> > > > > 
> > > > > If it's safe to race clear_page_dirty*() it has to be stated explicitly
> > > > > with a reason why. It's not very clear to me as it is.
> > > > 
> > > > The PageDirty() optimization above is fine to race with clear the
> > > > page flag as it means it is racing after a page_mkclean() and the
> > > > GUP user is done with the page so page is about to be write back
> > > > ie if (!PageDirty(page)) see the page as dirty and skip the sdf()
> > > > call while a split second after TestClearPageDirty() happens then
> > > > it means the racing clear is about to write back the page so all
> > > > is fine (the page was dirty and it is being clear for write back).
> > > > 
> > > > If it does call the sdf() while racing with write back then we
> > > > just redirtied the page just like clear_page_dirty_for_io() would
> > > > do if page_mkclean() failed so nothing harmful will come of that
> > > > neither. Page stays dirty despite write back it just means that
> > > > the page might be write back twice in a row.
> > > 
> > > Forgot to mention one thing, we had a discussion with Andrea and Jan
> > > about set_page_dirty() and Andrea had the good idea of maybe doing
> > > the set_page_dirty() at GUP time (when GUP with write) not when the
> > > GUP user calls put_page(). We can do that by setting the dirty bit
> > > in the pte for instance. They are few bonus of doing things that way:
> > >     - amortize the cost of calling set_page_dirty() (ie one call for
> > >       GUP and page_mkclean()
> > >     - it is always safe to do so at GUP time (ie the pte has write
> > >       permission and thus the page is in correct state)
> > >     - safe from truncate race
> > >     - no need to ever lock the page
> > 
> > I seem to have missed this conversation, so please excuse me for
> 
> The set_page_dirty() at GUP was in a private discussion (it started
> on another topic and drifted away to set_page_dirty()).
> 
> > asking a stupid question: if it's a file backed page, what prevents
> > background writeback from cleaning the dirty page ~30s into a long
> > term pin? i.e. I don't see anything in this proposal that prevents
> > the page from being cleaned by writeback and putting us straight
> > back into the situation where a long term RDMA is writing to a clean
> > page....
> 
> So this patchset does not solve this issue.

OK, so it just kicks the can further down the road.

>     [3..N] decide what to do for GUPed page, so far the plans seems
>          to be to keep the page always dirty and never allow page
>          write back to restore the page in a clean state. This does
>          disable thing like COW and other fs feature but at least
>          it seems to be the best thing we can do.

So the plan for GUP vs writeback so far is "break fsync()"? :)

We might need to work on that a bit more...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

