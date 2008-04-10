Date: Thu, 10 Apr 2008 10:10:24 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: git-slub crashes on the t16p
In-Reply-To: <47FE37D0.5030004@cs.helsinki.fi>
Message-ID: <Pine.LNX.4.64.0804101009220.11468@schroedinger.engr.sgi.com>
References: <20080410015958.bc2fd041.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0804101327190.15828@sbz-30.cs.Helsinki.FI>
 <47FE37D0.5030004@cs.helsinki.fi>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 10 Apr 2008, Pekka Enberg wrote:

> Somehow s->node[node] gets to be 0x64 which makes no sense. I checked my logs
> and I hit the exact same problem but it went away with "make clean". Andrew,
> can you please try that as well?

Memory corruption? 0x64 is 100 btw.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
