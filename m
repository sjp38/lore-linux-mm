Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 368BC6B00B4
	for <linux-mm@kvack.org>; Thu, 30 Dec 2010 17:04:19 -0500 (EST)
Received: (from localhost user: 'dkiper' uid#4000 fake: STDIN
	(dkiper@router-fw.net-space.pl)) by router-fw-old.local.net-space.pl
	id S1558450Ab0L3WC3 (ORCPT <rfc822;linux-mm@kvack.org>);
	Thu, 30 Dec 2010 23:02:29 +0100
Date: Thu, 30 Dec 2010 23:02:28 +0100
From: Daniel Kiper <dkiper@net-space.pl>
Subject: Re: [PATCH R2 5/7] xen/balloon: Protect before CPU exhaust by event/x process
Message-ID: <20101230220228.GA17191@router-fw-old.local.net-space.pl>
References: <20101229170541.GJ2743@router-fw-old.local.net-space.pl> <20101230162611.GA24313@dumpdata.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101230162611.GA24313@dumpdata.com>
Sender: owner-linux-mm@kvack.org
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Daniel Kiper <dkiper@net-space.pl>, ian.campbell@citrix.com, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, Dec 30, 2010 at 11:26:11AM -0500, Konrad Rzeszutek Wilk wrote:
> > -static int increase_reservation(unsigned long nr_pages)
> > +static enum bp_state increase_reservation(unsigned long nr_pages)
> >  {
> > +	enum bp_state state = BP_DONE;
> > +	int rc;
> >  	unsigned long  pfn, i, flags;
> >  	struct page   *page;
> > -	long           rc;
>
> How come? Is it just a cleanup?

I forgot to move it to separate patch. When I was working
on protection before CPU exhaust I discovered that
HYPERVISOR_memory_op() returns int and rc could be
declared as int not as long.

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
