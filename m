Date: Thu, 1 May 2008 12:23:04 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 02/18] hugetlb: factor out huge_new_page
In-Reply-To: <20080430204428.GC6903@us.ibm.com>
Message-ID: <Pine.LNX.4.64.0805011222350.8738@schroedinger.engr.sgi.com>
References: <20080423015302.745723000@nick.local0.net>
 <20080423015429.834926000@nick.local0.net> <20080424235431.GB4741@us.ibm.com>
 <20080424235829.GC4741@us.ibm.com> <481183FC.9060408@firstfloor.org>
 <20080425165424.GA9680@us.ibm.com> <Pine.LNX.4.64.0804251210530.5971@schroedinger.engr.sgi.com>
 <20080425192942.GB14623@us.ibm.com> <Pine.LNX.4.64.0804301215220.27955@schroedinger.engr.sgi.com>
 <20080430204428.GC6903@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Andi Kleen <andi@firstfloor.org>, npiggin@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org, kniht@linux.vnet.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On Wed, 30 Apr 2008, Nishanth Aravamudan wrote:

> Sure, my point was that we already have the nid in the caller (because
> we specify it along with GFP_THISNODE). So if we pass that nid down into
> this new function, we shoulnd't need to do the page_to_nid() call,
> right?

Right. But its safer the to page_to_nid() there. In case we do an alloc 
without __GFP_THISNODE in the future.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
