From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: RE: [RFC] reduce hugetlb_instantiation_mutex usage
Date: Mon, 30 Oct 2006 21:15:20 -0800
Message-ID: <000001c6fcab$8fe56320$5181030a@amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
In-Reply-To: <20061031031703.GA7220@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'David Gibson' <david@gibson.dropbear.id.au>, g@ozlabs.org
Cc: Andrew Morton <akpm@osdl.org>, 'Christoph Lameter' <christoph@schroedinger.engr.sgi.com>, Hugh Dickins <hugh@veritas.com>, bill.irwin@oracle.com, Adam Litke <agl@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

David Gibson wrote on Monday, October 30, 2006 7:17 PM
> > I got side tracked on to the radix-tree stuff.  The comments in
> > hugetlb_no_page() make me wonder whether we have a race issue on
> > private mapping:
> > 
> >         /*
> >          * Use page lock to guard against racing truncation
> >          * before we get page_table_lock.
> >          */
> > 
> > Private mapping won't use radix tree during instantiation.  What protects
> > racy truncate against fault in that scenario?  Don't we have a bug here?
> 
> Not at present, because the hugetlb_instantiation_mutex protects both
> fault paths.  But with Andrew's patch as it stands, yes.  As I said in
> a previous email.  The libhugetlbfs testsuite now has a testcase for
> the MAP_PRIVATE as well as the MAP_SHARED version of the race.


That's not what I'm saying.  I should've said I'm off topic and not talking
about parallel fault for private mapping.

Instead, I'm asking how private mapping protect race between file truncation
and fault? For shared mapping, it is clear to me that we are using lock_page
to protect file truncate with fault.  But I don't see that protection with
private mapping in current upstream kernel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
