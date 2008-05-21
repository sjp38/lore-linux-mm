Date: Tue, 20 May 2008 18:52:03 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] nommu: Push kobjsize() slab-specific logic down to
 ksize().
In-Reply-To: <20080521011925.GB24455@linux-sh.org>
Message-ID: <Pine.LNX.4.64.0805201851130.12548@schroedinger.engr.sgi.com>
References: <20080520095935.GB18633@linux-sh.org> <2373.1211296724@redhat.com>
 <Pine.LNX.4.64.0805200944210.6135@schroedinger.engr.sgi.com>
 <1211307820.18026.190.camel@calx> <Pine.LNX.4.64.0805201149270.10868@schroedinger.engr.sgi.com>
 <1211310023.18026.210.camel@calx> <Pine.LNX.4.64.0805201206040.10964@schroedinger.engr.sgi.com>
 <1211310896.18026.214.camel@calx> <Pine.LNX.4.64.0805201215330.11020@schroedinger.engr.sgi.com>
 <1211318557.18026.215.camel@calx> <20080521011925.GB24455@linux-sh.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Mundt <lethal@linux-sh.org>
Cc: Matt Mackall <mpm@selenic.com>, David Howells <dhowells@redhat.com>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 21 May 2008, Paul Mundt wrote:

> Having WARN_ON()'s for !PageSlab() pages in ksize() in SLAB/SLUB would
> make these cases more visible, at least.

SLUB/SLOB do not mark objects allocated via pass through to the page 
allocators with PageSlab.  WARN_ON would give false positives.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
