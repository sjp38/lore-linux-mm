Date: Thu, 25 Aug 2005 17:01:44 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: Zoned CART
In-Reply-To: <1125009555.20161.33.camel@twins>
Message-ID: <Pine.LNX.4.62.0508251657530.8955@schroedinger.engr.sgi.com>
References: <1123857429.14899.59.camel@twins>  <1124024312.30836.26.camel@twins>
 <1124141492.15180.22.camel@twins>  <43024435.90503@andrew.cmu.edu>
 <Pine.LNX.4.62.0508161318420.7906@schroedinger.engr.sgi.com>
 <1125009555.20161.33.camel@twins>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Rahul Iyer <rni@andrew.cmu.edu>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>
List-ID: <linux-mm.kvack.org>

On Fri, 26 Aug 2005, Peter Zijlstra wrote:

> This is with a rahul's 3 list approach:
>   active_list <-> T1, 
>   active_longterm <-> T2

longterm == T2? That wont work. longterm (L) is composed of T2 and a 
subset of T1.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
