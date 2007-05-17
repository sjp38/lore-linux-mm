Date: Thu, 17 May 2007 12:24:54 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 0/5] make slab gfp fair
In-Reply-To: <1179429499.2925.26.camel@lappy>
Message-ID: <Pine.LNX.4.64.0705171220120.3043@schroedinger.engr.sgi.com>
References: <20070514131904.440041502@chello.nl>
 <Pine.LNX.4.64.0705161957440.13458@schroedinger.engr.sgi.com>
 <1179385718.27354.17.camel@twins>  <Pine.LNX.4.64.0705171027390.17245@schroedinger.engr.sgi.com>
  <20070517175327.GX11115@waste.org>  <Pine.LNX.4.64.0705171101360.18085@schroedinger.engr.sgi.com>
 <1179429499.2925.26.camel@lappy>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Thu, 17 May 2007, Peter Zijlstra wrote:

> The proposed patch doesn't change how the kernel functions at this
> point; it just enforces an existing rule better.

Well I'd say it controls the allocation failures. And that only works if 
one can consider the system having a single zone.

Lets say the system has two cpusets A and B. A allocs from node 1 and B 
allocs from node 2. Two processes one in A and one in B run on the same 
processor.

Node 1 gets very low in memory so your patch kicks in and sets up the 
global memory emergency situation with the reserve slab.

Now the process in B will either fail although it has plenty of memory on 
node 2.

Or it may just clear the emergency slab and then the next critical alloc 
of the process in A that is low on memory will fail.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
