Date: Thu, 10 Apr 2008 10:54:53 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: git-slub crashes on the t16p
In-Reply-To: <47FE523B.80100@cs.helsinki.fi>
Message-ID: <Pine.LNX.4.64.0804101053370.12130@schroedinger.engr.sgi.com>
References: <20080410015958.bc2fd041.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0804101327190.15828@sbz-30.cs.Helsinki.FI>
 <47FE37D0.5030004@cs.helsinki.fi> <47FE41EE.8040402@cs.helsinki.fi>
 <20080410102454.8248e0ae.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0804101029270.11781@schroedinger.engr.sgi.com>
 <47FE5137.4000605@cs.helsinki.fi> <47FE523B.80100@cs.helsinki.fi>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, mel@skynet.ie
List-ID: <linux-mm.kvack.org>

One thing that does not make sense is that there was 0x64 in there. All 
unused node pointers should be NULL (they are zapped in 
kmem_cache_open()). So there may still be something else at play.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
