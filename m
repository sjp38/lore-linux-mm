Date: Fri, 1 Jun 2007 12:38:03 +0300
Subject: Re: [PATCH] Document Linux Memory Policy
Message-ID: <20070601093803.GE10459@minantech.com>
References: <1180467234.5067.52.camel@localhost> <1180637765.5091.153.camel@localhost> <20070531200644.GD10459@minantech.com> <200705312243.20242.ak@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200705312243.20242.ak@suse.de>
From: glebn@voltaire.com (Gleb Natapov)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <clameter@sgi.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, May 31, 2007 at 10:43:19PM +0200, Andi Kleen wrote:
> 
> > > > Do I
> > > > miss something here?
> > > 
> > > I think you do.  
> > OK. It seems I missed the fact that VMA policy is completely ignored for
> > pagecache backed files and only task policy is used. 
> 
> That's not correct. tmpfs is page cache backed and supports (even shared) VMA policy.
> hugetlbfs used to too, but lost its ability, but will hopefully get it again.
> 
This is even more confusing. So numa_*_memory() works different
depending on where file is created. I can't rely on this anyway and
have to assume that numa_*_memory() call is ignored and prefault.
I think Lee's patches should be applied ASAP to fix this inconsistency.

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
