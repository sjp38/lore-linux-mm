Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 80A5A6B01D5
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 13:40:21 -0400 (EDT)
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e1.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o5EHYFRh017510
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 13:34:15 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o5EHeHmx090248
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 13:40:17 -0400
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o5EHeEZE021403
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 11:40:14 -0600
Date: Mon, 14 Jun 2010 23:10:08 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC/T/D][PATCH 2/2] Linux/Guest cooperative unmapped page cache
 control
Message-ID: <20100614174008.GA5191@balbir.in.ibm.com>
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
 <4C164C22.1050503@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <4C164C22.1050503@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, kvm <kvm@vger.kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* Avi Kivity <avi@redhat.com> [2010-06-14 18:34:58]:

> On 06/14/2010 06:12 PM, Dave Hansen wrote:
> >On Mon, 2010-06-14 at 14:18 +0530, Balbir Singh wrote:
> >>1. A slab page will not be freed until the entire page is free (all
> >>slabs have been kfree'd so to speak). Normal reclaim will definitely
> >>free this page, but a lot of it depends on how frequently we are
> >>scanning the LRU list and when this page got added.
> >You don't have to be freeing entire slab pages for the reclaim to have
> >been useful.  You could just be making space so that _future_
> >allocations fill in the slab holes you just created.  You may not be
> >freeing pages, but you're reducing future system pressure.
> 
> Depends.  If you've evicted something that will be referenced soon,
> you're increasing system pressure.
>

I don't think slab pages care about being referenced soon, they are
either allocated or freed. A page is just a storage unit for the data
structure. A new one can be allocated on demand.
 
 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
