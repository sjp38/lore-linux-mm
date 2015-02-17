Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 76CB96B0032
	for <linux-mm@kvack.org>; Tue, 17 Feb 2015 00:23:42 -0500 (EST)
Received: by padfa1 with SMTP id fa1so3638622pad.2
        for <linux-mm@kvack.org>; Mon, 16 Feb 2015 21:23:42 -0800 (PST)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id j14si6530761pdm.24.2015.02.16.21.23.40
        for <linux-mm@kvack.org>;
        Mon, 16 Feb 2015 21:23:41 -0800 (PST)
Date: Tue, 17 Feb 2015 14:26:13 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 2/3] slub: Support for array operations
Message-ID: <20150217052612.GD15413@js1304-P5Q-DELUXE>
References: <20150210194804.288708936@linux.com>
 <20150210194811.902155759@linux.com>
 <20150213024515.GB6592@js1304-P5Q-DELUXE>
 <alpine.DEB.2.11.1502130948120.9442@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1502130948120.9442@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: akpm@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, penberg@kernel.org, iamjoonsoo@lge.com, Jesper Dangaard Brouer <brouer@redhat.com>

On Fri, Feb 13, 2015 at 09:49:24AM -0600, Christoph Lameter wrote:
> On Fri, 13 Feb 2015, Joonsoo Kim wrote:
> 
> > > +			*p++ = freelist;
> > > +			freelist = get_freepointer(s, freelist);
> > > +			allocated++;
> > > +		}
> >
> > Fetching all objects with holding node lock could result in enomourous
> > lock contention. How about getting free ojbect pointer without holding
> > the node lock? We can temporarilly store all head of freelists in
> > array p and can fetch each object pointer without holding node lock.
> 
> 
> Could do that but lets first see if there is really an issue. The other
> cpu sharing the same partial lists presumaly have cpu local objects to get
> through first before they hit this lock.

Okay.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
