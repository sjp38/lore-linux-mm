From: David Howells <dhowells@redhat.com>
In-Reply-To: <20080520095935.GB18633@linux-sh.org>
References: <20080520095935.GB18633@linux-sh.org>
Subject: Re: [PATCH] nommu: Push kobjsize() slab-specific logic down to ksize().
Date: Tue, 20 May 2008 16:18:44 +0100
Message-ID: <2373.1211296724@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Mundt <lethal@linux-sh.org>
Cc: dhowells@redhat.com, Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <clameter@sgi.com>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Paul Mundt <lethal@linux-sh.org> wrote:

> Moving the existing logic in to SLAB's ksize() and simply wrapping in to
> ksize() directly seems to do the right thing in all cases, and allows me
> to boot with any of the slab allocators enabled, rather than simply SLAB
> by itself.
> 
> I've done the same !PageSlab() test in SLAB as SLUB does in its ksize(),
> which also seems to produce the correct results. Hopefully someone more
> familiar with the history of kobjsize()/ksize() interaction can scream if
> this is the wrong thing to do. :-)

That seems reasonable.  I can't test it until I get back to the UK next week.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
