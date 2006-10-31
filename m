Date: Tue, 31 Oct 2006 12:48:13 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [RFC] reduce hugetlb_instantiation_mutex usage
In-Reply-To: <20061031110540.GA14172@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0610311239460.6523@blonde.wat.veritas.com>
References: <20061031031703.GA7220@localhost.localdomain>
 <000001c6fcab$8fe56320$5181030a@amr.corp.intel.com>
 <20061031110540.GA14172@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'David Gibson' <david@gibson.dropbear.id.au>
Cc: "Chen, Kenneth W" <kenneth.w.chen@intel.com>, g@ozlabs.org, Andrew Morton <akpm@osdl.org>, 'Christoph Lameter' <christoph@schroedinger.engr.sgi.com>, bill.irwin@oracle.com, Adam Litke <agl@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 31 Oct 2006, 'David Gibson' wrote:
> On Mon, Oct 30, 2006 at 09:15:20PM -0800, Chen, Kenneth W wrote:
> > 
> > Instead, I'm asking how private mapping protect race between file truncation
> > and fault? For shared mapping, it is clear to me that we are using lock_page
> > to protect file truncate with fault.  But I don't see that protection with
> > private mapping in current upstream kernel.
> 
> Oh, ok.  I can't see how it matters in the PRIVATE case, given that
> truncate() won't, and shouldn't, truncate privately mapped pages.

Bzzt, it does and should (unless we decide to make hugetlbfs pages diverge
from the standard for ordinary pages in this respect - could do, but that
would require thought of its own).  If you've been thinking otherwise,
that may explain why some of the accounting goes wrong.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
