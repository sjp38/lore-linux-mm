Date: Thu, 31 May 2007 14:59:31 +0300
Subject: Re: [PATCH] Document Linux Memory Policy
Message-ID: <20070531115931.GO4715@minantech.com>
References: <1180467234.5067.52.camel@localhost> <200705311243.20119.ak@suse.de> <20070531110412.GM4715@minantech.com> <200705311347.28214.ak@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200705311347.28214.ak@suse.de>
From: glebn@voltaire.com (Gleb Natapov)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, May 31, 2007 at 01:47:28PM +0200, Andi Kleen wrote:
> 
> > No it is not (not always).
> 
> Natural = as in benefits a large number of application. Your requirement
> seems to be quite special.
Really. Is use of shared memory to communicate between two processes so
rare and special?

> 
> > I want to create shared memory for 
> > interprocess communication. Process A will write into the memory and
> > process B will periodically poll it to see if there is a message there.
> > In NUMA system I want the physical memory for this VMA to be allocated
> > from node close to process B 
> 
> Then bind it to the node of process B (using numa_set_membind())
> 
Already found it. Thanks.

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
