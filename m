Date: Thu, 16 Feb 2006 09:01:51 -0600
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: pluggable reclaim infrastructure
Message-ID: <20060216150151.GA24842@dmt.cnet>
References: <Pine.LNX.4.62.0602111335560.24685@schroedinger.engr.sgi.com> <20060211135031.623fdef9.akpm@osdl.org> <Pine.LNX.4.62.0602111424050.24990@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.62.0602111424050.24990@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>, Peter Zijlstra <peter@programming.kicks-ass.net>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, nickpiggin@yahoo.com.au, Bob Picco <bob.picco@hp.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Sat, Feb 11, 2006 at 02:25:57PM -0800, Christoph Lameter wrote:
> Here is a new rev of the earlier patch that moves the determination of
> reclaim_mapped into shrink_zone(). This means that refill_inactive does 
> not depend on scan control anymore. And its properly formatted for 80 
> columns

Can we please hold off this reclaim tweaks for a while? Peter's
pluggable page-replace infrastructure does more fundamental and
important changes to the reclaim code (along with better organization
and separation of the heuristics such as reclaim_mapped, etc.), and
having vmscan.c to change often (as it is now) is just a pain in the
arse to handle.

Its not going to take long for the patchset to be sent for
review/shaping.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
