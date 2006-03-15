Subject: Re: [PATCH/RFC] AutoPage Migration - V0.1 - 0/8 Overview
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Reply-To: lee.schermerhorn@hp.com
In-Reply-To: <Pine.LNX.4.64.0603151019490.27289@schroedinger.engr.sgi.com>
References: <1142019195.5204.12.camel@localhost.localdomain>
	 <20060311154113.c4358e40.kamezawa.hiroyu@jp.fujitsu.com>
	 <1142270857.5210.50.camel@localhost.localdomain>
	 <Pine.LNX.4.64.0603131541330.13713@schroedinger.engr.sgi.com>
	 <44183B64.3050701@argo.co.il> <20060315095426.b70026b8.pj@sgi.com>
	 <Pine.LNX.4.64.0603151008570.27212@schroedinger.engr.sgi.com>
	 <20060315101402.3b19330c.pj@sgi.com>
	 <Pine.LNX.4.64.0603151019490.27289@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Wed, 15 Mar 2006 14:21:58 -0500
Message-Id: <1142450519.5198.8.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Paul Jackson <pj@sgi.com>, avi@argo.co.il, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, Peter Chubb <peterc@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

On Wed, 2006-03-15 at 10:20 -0800, Christoph Lameter wrote:
> On Wed, 15 Mar 2006, Paul Jackson wrote:
> 
> > The point was to copy pages that receive many
> > load and store instructions from far away nodes.
> 
> Right. In order to do that we first need to have some memory traces or 
> statistics that can establish that a page is accessed from far away nodes.
> 

The guys down at UNSW have patches for the ia64 that can show numa
accesses.  The patches are based on their long format vhpt tlb miss
handler.  As such, it can only report when a pages misses in the tlb,
but that's more that we have now.  I believe that they have a "numa
visualization" tool to display the results graphically, as well.





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
