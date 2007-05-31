Date: Thu, 31 May 2007 15:18:54 +0300
Subject: Re: [PATCH] Document Linux Memory Policy
Message-ID: <20070531121854.GP4715@minantech.com>
References: <1180467234.5067.52.camel@localhost> <200705311347.28214.ak@suse.de> <20070531115931.GO4715@minantech.com> <200705311415.11170.ak@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200705311415.11170.ak@suse.de>
From: glebn@voltaire.com (Gleb Natapov)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, May 31, 2007 at 02:15:11PM +0200, Andi Kleen wrote:
> On Thursday 31 May 2007 13:59:31 Gleb Natapov wrote:
> > On Thu, May 31, 2007 at 01:47:28PM +0200, Andi Kleen wrote:
> > > 
> > > > No it is not (not always).
> > > 
> > > Natural = as in benefits a large number of application. Your requirement
> > > seems to be quite special.
> > Really. Is use of shared memory to communicate between two processes so
> > rare and special?
> 
> It is more rare that not the first process touching memory is using it more often.
> It tends to happen with some memory allocators that reuse memory, but there
> is no reasonable way except asking for explicit policy to handle that anyways.
> 
OK. It is possible to achieve exactly what I need with existing API and this is what
matters. Thanks.

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
