Date: Tue, 31 Jul 2007 12:18:29 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [rfc] [patch] mm: zone_reclaim fix for pseudo file systems
In-Reply-To: <20070731071502.GA7316@localdomain>
Message-ID: <Pine.LNX.4.64.0707311217540.6093@schroedinger.engr.sgi.com>
References: <20070730132314.f6c8b4e1.akpm@linux-foundation.org>
 <20070731000138.GA32468@localdomain> <20070730172007.ddf7bdee.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0707301725280.25686@schroedinger.engr.sgi.com>
 <20070731015647.GC32468@localdomain> <Pine.LNX.4.64.0707301858280.26859@schroedinger.engr.sgi.com>
 <20070730192721.eb220a9d.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0707301934300.27364@schroedinger.engr.sgi.com>
 <20070730214756.c4211678.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0707302156440.30284@schroedinger.engr.sgi.com>
 <20070731071502.GA7316@localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ravikiran G Thirumalai <kiran@scalex86.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, shai@scalex86.org
List-ID: <linux-mm.kvack.org>

On Tue, 31 Jul 2007, Ravikiran G Thirumalai wrote:

> >I am going over my old patchsets anyways. Kiran: Did you have a look at 
> >the patches Nick and I did earlier this year for mlocked pages?
> 
> Yes.  I guess it is good to move unrelclaimable pages off LRU.  But we still
> need to not get into reclaim when we don't have pages to reclaim.  That is,
> fix the arithmetic here.  No?

The arithmetic will be fixed automatically if these pages do not end up
on the LRU. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
