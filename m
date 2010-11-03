Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id E8DE26B00BA
	for <linux-mm@kvack.org>; Wed,  3 Nov 2010 13:17:41 -0400 (EDT)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id oA3H6Jhj009482
	for <linux-mm@kvack.org>; Wed, 3 Nov 2010 11:06:19 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id oA3HHZVA256766
	for <linux-mm@kvack.org>; Wed, 3 Nov 2010 11:17:35 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oA3HHZk8026147
	for <linux-mm@kvack.org>; Wed, 3 Nov 2010 11:17:35 -0600
Date: Wed, 3 Nov 2010 22:47:33 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 1/3] Linux/Guest unmapped page cache control
Message-ID: <20101103171733.GP3769@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20101028224002.32626.13015.sendpatchset@localhost.localdomain>
 <20101028224008.32626.69769.sendpatchset@localhost.localdomain>
 <alpine.DEB.2.00.1011030932260.10599@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1011030932260.10599@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, qemu-devel@nongnu.org
List-ID: <linux-mm.kvack.org>

* Christoph Lameter <cl@linux.com> [2010-11-03 09:35:33]:

> On Fri, 29 Oct 2010, Balbir Singh wrote:
> 
> > A lot of the code is borrowed from zone_reclaim_mode logic for
> > __zone_reclaim(). One might argue that the with ballooning and
> > KSM this feature is not very useful, but even with ballooning,
> 
> Interesting use of zone reclaim. I am having a difficult time reviewing
> the patch since you move and modify functions at the same time. Could you
> separate that out a bit?
>

Sure, I'll split it out into more readable bits and repost the mm
versions first.
 
> > +#define UNMAPPED_PAGE_RATIO 16
> 
> Maybe come up with a scheme that allows better configuration of the
> mininum? I think in some setting we may want an absolute limit and in
> other a fraction of something (total zone size or working set?)
>

Are you suggesting a sysctl or computation based on zone size and
limit, etc? I understand it to be the latter.
 
> 
> > +bool should_balance_unmapped_pages(struct zone *zone)
> > +{
> > +	if (unmapped_page_control &&
> > +		(zone_unmapped_file_pages(zone) >
> > +			UNMAPPED_PAGE_RATIO * zone->min_unmapped_pages))
> > +		return true;
> > +	return false;
> > +}
> 

Thanks for your review.

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
