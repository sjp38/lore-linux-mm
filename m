Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id D1C626B01CA
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 12:59:06 -0400 (EDT)
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e9.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o5EGiEYB020906
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 12:44:14 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o5EGwvgN138490
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 12:58:57 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o5EGwvFL022588
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 13:58:57 -0300
Date: Mon, 14 Jun 2010 22:28:53 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC/T/D][PATCH 2/2] Linux/Guest cooperative unmapped page cache
 control
Message-ID: <20100614165853.GW5191@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20100608155140.3749.74418.sendpatchset@L34Z31A.ibm.com>
 <20100608155153.3749.31669.sendpatchset@L34Z31A.ibm.com>
 <4C10B3AF.7020908@redhat.com>
 <20100610142512.GB5191@balbir.in.ibm.com>
 <1276214852.6437.1427.camel@nimitz>
 <20100611045600.GE5191@balbir.in.ibm.com>
 <4C15E3C8.20407@redhat.com>
 <20100614084810.GT5191@balbir.in.ibm.com>
 <1276528376.6437.7176.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1276528376.6437.7176.camel@nimitz>
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Avi Kivity <avi@redhat.com>, kvm <kvm@vger.kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* Dave Hansen <dave@linux.vnet.ibm.com> [2010-06-14 08:12:56]:

> On Mon, 2010-06-14 at 14:18 +0530, Balbir Singh wrote:
> > 1. A slab page will not be freed until the entire page is free (all
> > slabs have been kfree'd so to speak). Normal reclaim will definitely
> > free this page, but a lot of it depends on how frequently we are
> > scanning the LRU list and when this page got added.
> 
> You don't have to be freeing entire slab pages for the reclaim to have
> been useful.  You could just be making space so that _future_
> allocations fill in the slab holes you just created.  You may not be
> freeing pages, but you're reducing future system pressure.
> 
> If unmapped page cache is the easiest thing to evict, then it should be
> the first thing that goes when a balloon request comes in, which is the
> case this patch is trying to handle.  If it isn't the easiest thing to
> evict, then we _shouldn't_ evict it.
>

Like I said earlier, a lot of that works correctly as you said, but it
is also an idealization. If you've got duplicate pages and you know
that they are duplicated and can be retrieved at a lower cost, why
wouldn't we go after them first?

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
