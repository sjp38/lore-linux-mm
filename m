Date: Mon, 19 Jun 2006 14:48:33 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC][PATCH] inactive_clean
In-Reply-To: <1150749971.28517.122.camel@lappy>
Message-ID: <Pine.LNX.4.64.0606191442450.4739@schroedinger.engr.sgi.com>
References: <1150719606.28517.83.camel@lappy>
 <Pine.LNX.4.64.0606190837450.1184@schroedinger.engr.sgi.com>
 <1150740624.28517.108.camel@lappy>  <Pine.LNX.4.64.0606191202350.23422@schroedinger.engr.sgi.com>
  <Pine.LNX.4.64.0606191509490.6565@cuia.boston.redhat.com>
 <Pine.LNX.4.64.0606191223410.3925@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0606191526401.6565@cuia.boston.redhat.com>
 <Pine.LNX.4.64.0606191257100.3993@schroedinger.engr.sgi.com>
 <1150747501.28517.114.camel@lappy>  <Pine.LNX.4.64.0606191308470.4203@schroedinger.engr.sgi.com>
 <1150749971.28517.122.camel@lappy>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Rik van Riel <riel@redhat.com>, Linus Torvalds <torvalds@osdl.org>, Andi Kleen <ak@suse.de>, Rohit Seth <rohitseth@google.com>, Andrew Morton <akpm@osdl.org>, mbligh@google.com, hugh@veritas.com, andrea@suse.de, arjan@infradead.org, apw@shadowen.org, mel@csn.ul.ie, marcelo@kvack.org, anton@samba.org, paulmck@us.ibm.com, Nick Piggin <piggin@cyberone.com.au>, linux-mm <linux-mm@kvack.org>, Nikita Danilov <nikita@clusterfs.com>
List-ID: <linux-mm.kvack.org>

On Mon, 19 Jun 2006, Peter Zijlstra wrote:

> You need to increase nr_clean_anon to reach nr_wanted_clean.

nr_clean_anon? Anonymous pages are always dirty! They may appear to be 
clean for a process but fundamentally a clean anonymous page is full of 
zeros. We use a special page for that.

> But you need slightly more than just writeout, you need to create a
> clean anonymous page, so you need to keep it around.

Still boogling on the clean anonymous pages. Maybe with swap you can get
there. You mean the anonymous page is clean when it was written to swap? 
We are dealing with a special case here when the performance already 
sucks and now we add more logic to make the case when performance was not 
bad worse?

If an anonymus page gains a reference to swap then it is fundamentally no 
longer a pure anonymous page.

> LRU page order, and having a preference for file-backed pages breaks it.

zone_reclaim already does not observe that order but goes for the easily 
reclaimable unmapped pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
