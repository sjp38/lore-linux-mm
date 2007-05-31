From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] Document Linux Memory Policy
Date: Thu, 31 May 2007 14:15:11 +0200
References: <1180467234.5067.52.camel@localhost> <200705311347.28214.ak@suse.de> <20070531115931.GO4715@minantech.com>
In-Reply-To: <20070531115931.GO4715@minantech.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200705311415.11170.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gleb Natapov <glebn@voltaire.com>
Cc: Christoph Lameter <clameter@sgi.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thursday 31 May 2007 13:59:31 Gleb Natapov wrote:
> On Thu, May 31, 2007 at 01:47:28PM +0200, Andi Kleen wrote:
> > 
> > > No it is not (not always).
> > 
> > Natural = as in benefits a large number of application. Your requirement
> > seems to be quite special.
> Really. Is use of shared memory to communicate between two processes so
> rare and special?

It is more rare that not the first process touching memory is using it more often.
It tends to happen with some memory allocators that reuse memory, but there
is no reasonable way except asking for explicit policy to handle that anyways.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
