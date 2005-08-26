Subject: Re: Zoned CART
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <Pine.LNX.4.62.0508251657530.8955@schroedinger.engr.sgi.com>
References: <1123857429.14899.59.camel@twins>
	 <1124024312.30836.26.camel@twins> <1124141492.15180.22.camel@twins>
	 <43024435.90503@andrew.cmu.edu>
	 <Pine.LNX.4.62.0508161318420.7906@schroedinger.engr.sgi.com>
	 <1125009555.20161.33.camel@twins>
	 <Pine.LNX.4.62.0508251657530.8955@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Fri, 26 Aug 2005 09:09:33 +0200
Message-Id: <1125040173.20161.39.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Rahul Iyer <rni@andrew.cmu.edu>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2005-08-25 at 17:01 -0700, Christoph Lameter wrote:
> On Fri, 26 Aug 2005, Peter Zijlstra wrote:
> 
> > This is with a rahul's 3 list approach:
> >   active_list <-> T1, 
> >   active_longterm <-> T2
> 
> longterm == T2? That wont work. longterm (L) is composed of T2 and a 
> subset of T1.

As Rahul said, this is a misnomer, the list is actually used as T2,
but my question remains should (on a stock kernel):

 zone->present_pages - zone->free_pages = 
                           zone->nr_active + zone->nr_inactive

Or is there some other place the pages can go?
-- 
Peter Zijlstra <a.p.zijlstra@chello.nl>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
