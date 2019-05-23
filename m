Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D4268C282E1
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 22:36:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 940D520879
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 22:36:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 940D520879
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 12AC86B0003; Thu, 23 May 2019 18:36:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0B5E36B0005; Thu, 23 May 2019 18:36:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E97086B0006; Thu, 23 May 2019 18:36:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id AB38C6B0003
	for <linux-mm@kvack.org>; Thu, 23 May 2019 18:36:09 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id t1so5257184pfa.10
        for <linux-mm@kvack.org>; Thu, 23 May 2019 15:36:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ZGyH1pWFoXhq3bmqnWqDE5ln/9ZlxnnGBfR+BOXWDj4=;
        b=NrMq9F3ORFxIJydkXJTj1Uwrr4XOBMps9nvXUU7+NlUFT9f8VOa5PzLXAUSbypTVQZ
         zIopPa5THJarrfCuv73om4Pp2YT9pogKOwZ2Rd9H5JIfvNi43uXYi7G23mfhWfRBXTGH
         i0XBgotiZJygMv5h4549oevP5DI2ha+F1zf92BZLXD0/PiQ2ei2Zrh/SGhGTEH1Ggi3G
         za7/j1wpGJCAc2i8sxvu+3KRWlh1HTX2Dxy/emWabXm/F263ZxY+Kl3nQWAzInBefszi
         IpVv1Cd2Lo5budSOFa6AcPswNCx5bXg3qUtBtbrbyxpeqBqpGS0jkVpGFlJxiDl8vb66
         bKlg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAW5NttYr71RtG096Q0aKTRsaJ+x9WXutyoKx2nfLRojt9O/GMiz
	w+WqE06wnq5Az8pEFrg8qKH7DBjXbYNrpUfm3uHJMGKFveIm7hc+a6XQ8IPcGXrnpobwWIBkCAc
	Jafg9mzNF522Ki+hzj5FZOLfNLqMqt44OblrBfECFB4VqvhqVPv2sJclXEhJ87UqlXA==
X-Received: by 2002:a63:d345:: with SMTP id u5mr96136999pgi.83.1558650969153;
        Thu, 23 May 2019 15:36:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwtOp/wkTYArI5tp1rFr3J4+zpcYGyCFdRlH1ye3nmlOvnZnEvHtZo3FVEFj7jnRM9NOdoN
X-Received: by 2002:a63:d345:: with SMTP id u5mr96136962pgi.83.1558650968345;
        Thu, 23 May 2019 15:36:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558650968; cv=none;
        d=google.com; s=arc-20160816;
        b=NzVknSuPOPufvgSJFjOQI8ViMpHRs9xCU6XKPBhM0NfsY77VTRU+ZMETDjj1/DUhFf
         LQEnnDH1RIjiLBTtk888tXi2eC6uMky5o89QaRC9p4GjcuQxK8/b7y5izwdrbrxOKN1A
         UqL72pezPwySKU1IGIsvL2uJucFI48DxMX9BXidiF8lLSap6pOeDZ4j0AK6f33SlNUAe
         NsfkD7Z9o611oJmJXTgajfiEc8DYj0otTCLvoY2SIEzL5oPoPwFNa0Xa5wnYgDumrJ9P
         1zBg6JYeYebncPa0cp0PrltjNS0efWtvBUe8UY1Q2ZD2ZXvxMRA4JkK4jpL98gUsmKuV
         tExw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ZGyH1pWFoXhq3bmqnWqDE5ln/9ZlxnnGBfR+BOXWDj4=;
        b=oJ1RDoxIQ4vET5yXnrFUuKBrqlJluPc4Da8rlr41u2188lM2Q8CAfzXTpVS5KsdNZd
         y1F3kAxYFDt5JmXTbbFme4u3zO/ZKRGBBjGllrnbjPLHWSl1qZAy7Kt9es+w7eko9K3J
         c9uRmxmVqiL25KpFcTkAmiyEecA95BqXFsn9KXbSsveyKWKwopDuQU3MTCL65pKrCyhp
         mJfd7qGbQ7vejmMkzmUdH9Bnd/Pu3C933jSaMBf4+7Ithfg0ujy3dXFPJ7FyjdCZ5F/+
         7sLzvJ+4W5fLofZtt2SzaH6VzcZ+qf0qE+L32o6Mh8Xfaoepz4jbmEmoUwWhaN0QhBhV
         TQNg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id z29si1542483pgk.276.2019.05.23.15.36.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 May 2019 15:36:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga008.fm.intel.com ([10.253.24.58])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 23 May 2019 15:36:07 -0700
X-ExtLoop1: 1
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga008.fm.intel.com with ESMTP; 23 May 2019 15:36:07 -0700
Date: Thu, 23 May 2019 15:37:01 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Jason Gunthorpe <jgg@mellanox.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	Doug Ledford <dledford@redhat.com>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Christian Benvenuti <benve@cisco.com>, Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 1/1] infiniband/mm: convert put_page() to put_user_page*()
Message-ID: <20190523223701.GA15048@iweiny-DESK2.sc.intel.com>
References: <20190523072537.31940-1-jhubbard@nvidia.com>
 <20190523072537.31940-2-jhubbard@nvidia.com>
 <20190523172852.GA27175@iweiny-DESK2.sc.intel.com>
 <20190523173222.GH12145@mellanox.com>
 <fa6d7d7c-13a3-0586-6384-768ebb7f0561@nvidia.com>
 <20190523190423.GA19578@iweiny-DESK2.sc.intel.com>
 <0bd9859f-8eb0-9148-6209-08ae42665626@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0bd9859f-8eb0-9148-6209-08ae42665626@nvidia.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 23, 2019 at 12:13:59PM -0700, John Hubbard wrote:
> On 5/23/19 12:04 PM, Ira Weiny wrote:
> > On Thu, May 23, 2019 at 10:46:38AM -0700, John Hubbard wrote:
> > > On 5/23/19 10:32 AM, Jason Gunthorpe wrote:
> > > > On Thu, May 23, 2019 at 10:28:52AM -0700, Ira Weiny wrote:
> > > > > > @@ -686,8 +686,8 @@ int ib_umem_odp_map_dma_pages(struct ib_umem_odp *umem_odp, u64 user_virt,
> > > > > >    			 * ib_umem_odp_map_dma_single_page().
> > > > > >    			 */
> > > > > >    			if (npages - (j + 1) > 0)
> > > > > > -				release_pages(&local_page_list[j+1],
> > > > > > -					      npages - (j + 1));
> > > > > > +				put_user_pages(&local_page_list[j+1],
> > > > > > +					       npages - (j + 1));
> > > > > 
> > > > > I don't know if we discussed this before but it looks like the use of
> > > > > release_pages() was not entirely correct (or at least not necessary) here.  So
> > > > > I think this is ok.
> > > > 
> > > > Oh? John switched it from a put_pages loop to release_pages() here:
> > > > 
> > > > commit 75a3e6a3c129cddcc683538d8702c6ef998ec589
> > > > Author: John Hubbard <jhubbard@nvidia.com>
> > > > Date:   Mon Mar 4 11:46:45 2019 -0800
> > > > 
> > > >       RDMA/umem: minor bug fix in error handling path
> > > >       1. Bug fix: fix an off by one error in the code that cleans up if it fails
> > > >          to dma-map a page, after having done a get_user_pages_remote() on a
> > > >          range of pages.
> > > >       2. Refinement: for that same cleanup code, release_pages() is better than
> > > >          put_page() in a loop.
> > > > 
> > > > And now we are going to back something called put_pages() that
> > > > implements the same for loop the above removed?
> > > > 
> > > > Seems like we are going in circles?? John?
> > > > 
> > > 
> > > put_user_pages() is meant to be a drop-in replacement for release_pages(),
> > > so I made the above change as an interim step in moving the callsite from
> > > a loop, to a single call.
> > > 
> > > And at some point, it may be possible to find a way to optimize put_user_pages()
> > > in a similar way to the batching that release_pages() does, that was part
> > > of the plan for this.
> > > 
> > > But I do see what you mean: in the interim, maybe put_user_pages() should
> > > just be calling release_pages(), how does that change sound?
> > 
> > I'm certainly not the expert here but FWICT release_pages() was originally
> > designed to work with the page cache.
> > 
> > aabfb57296e3  mm: memcontrol: do not kill uncharge batching in free_pages_and_swap_cache
> > 
> > But at some point it was changed to be more general?
> > 
> > ea1754a08476 mm, fs: remove remaining PAGE_CACHE_* and page_cache_{get,release} usage
> > 
> > ... and it is exported and used outside of the swapping code... and used at
> > lease 1 place to directly "put" pages gotten from get_user_pages_fast()
> > [arch/x86/kvm/svm.c]
> > 
> >  From that it seems like it is safe.
> > 
> > But I don't see where release_page() actually calls put_page() anywhere?  What
> > am I missing?
> > 
> 
> For that question, I recall having to look closely at this function, as well:
> 
> void release_pages(struct page **pages, int nr)
> {
> 	int i;
> 	LIST_HEAD(pages_to_free);
> 	struct pglist_data *locked_pgdat = NULL;
> 	struct lruvec *lruvec;
> 	unsigned long uninitialized_var(flags);
> 	unsigned int uninitialized_var(lock_batch);
> 
> 	for (i = 0; i < nr; i++) {
> 		struct page *page = pages[i];
> 
> 		/*
> 		 * Make sure the IRQ-safe lock-holding time does not get
> 		 * excessive with a continuous string of pages from the
> 		 * same pgdat. The lock is held only if pgdat != NULL.
> 		 */
> 		if (locked_pgdat && ++lock_batch == SWAP_CLUSTER_MAX) {
> 			spin_unlock_irqrestore(&locked_pgdat->lru_lock, flags);
> 			locked_pgdat = NULL;
> 		}
> 
> 		if (is_huge_zero_page(page))
> 			continue;
> 
> 		/* Device public page can not be huge page */
> 		if (is_device_public_page(page)) {
> 			if (locked_pgdat) {
> 				spin_unlock_irqrestore(&locked_pgdat->lru_lock,
> 						       flags);
> 				locked_pgdat = NULL;
> 			}
> 			put_devmap_managed_page(page);
> 			continue;
> 		}
> 
> 		page = compound_head(page);
> 		if (!put_page_testzero(page))
> 
> 		     ^here is where it does the put_page() call, is that what
> 			you were looking for?

Yes I saw that...

I've dug in further and I see now that release_pages() implements (almost the
same thing, see below) as put_page().

However, I think we need to be careful here because put_page_testzero() calls

	page_ref_dec_and_test(page);

... and after your changes it will need to call ...

	page_ref_sub_return(page, GUP_PIN_COUNTING_BIAS);

... on a GUP page:

So how do you propose calling release_pages() from within put_user_pages()?  Or
were you thinking this would be temporary?

That said, there are 2 differences I see between release_pages() and put_page()

1) release_pages() will only work for a MEMORY_DEVICE_PUBLIC page and not all
   devmem pages...
   I think this is a bug, patch to follow shortly.

2) release_pages() calls __ClearPageActive() while put_page() does not

I have no idea if the second difference is a bug or not.  But it smells of
one...

It would be nice to know if the open coding of put_page is really a performance
benefit or not.  It seems like an attempt to optimize the taking of the page
data lock.

Does anyone have any information about the performance advantage here?

Given the changes above it seems like it would be a benefit to merge the 2 call
paths more closely to make sure we do the right thing.

Ira

