Date: Thu, 28 Jun 2007 18:41:47 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH/RFC 0/11] Shared Policy Overview
In-Reply-To: <1182987407.7199.61.camel@localhost>
Message-ID: <Pine.LNX.4.64.0706281840210.9573@schroedinger.engr.sgi.com>
References: <20070625195224.21210.89898.sendpatchset@localhost>
 <Pine.LNX.4.64.0706261517050.21844@schroedinger.engr.sgi.com>
 <1182968078.4948.30.camel@localhost>  <Pine.LNX.4.64.0706271427400.31227@schroedinger.engr.sgi.com>
 <1182987407.7199.61.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: "Paul E. McKenney" <paulmck@us.ibm.com>, linux-mm@kvack.org, akpm@linux-foundation.org, nacc@us.ibm.com, ak@suse.de
List-ID: <linux-mm.kvack.org>

On Wed, 27 Jun 2007, Lee Schermerhorn wrote:

> > 1. The use is lightweight and does not impact performance.
> 
> I agree that use of memory policies should have a net decrease in
> performance.  However, nothing is for free.  It's a tradeoff.  If you
> don't need policies or if they hurt worse than they help, don't use
> them.  No performance impact.  If locality matters and policies help
> more than they cost, use them.  

Wel the current situation seems to be better AFAIK. Why tradeoff 
anything for less performance and more inconsistencies?

> Maybe.  or maybe something different.  Laudable goals, anyway.  Let's
> discuss in the NUMA BOF.

Would be good. I keep failing to see the point of all of this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
