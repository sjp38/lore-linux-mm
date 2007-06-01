From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] Document Linux Memory Policy
Date: Fri, 1 Jun 2007 15:09:18 +0200
References: <1180467234.5067.52.camel@localhost> <200706011221.33062.ak@suse.de> <20070601122514.GF10459@minantech.com>
In-Reply-To: <20070601122514.GF10459@minantech.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200706011509.18433.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gleb Natapov <glebn@voltaire.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <clameter@sgi.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> > > I can't rely on this anyway and 
> > > have to assume that numa_*_memory() call is ignored and prefault.
> > 
> > It's either use shared/anonymous memory or process policy.
> That is where confusion is. You use words "shared memory" here. Is shared
> memory created with mmap(MAP_SHARED) is not "shared" enough? 

It's file backed.

> > > I think Lee's patches should be applied ASAP to fix this inconsistency.
> > 
> > They have serious semantic problems.
> > 
> Can you point me to thread where this was discussed?

See the thread following the patches.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
