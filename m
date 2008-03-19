Date: Tue, 18 Mar 2008 21:13:49 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [git pull] slub fallback fix
In-Reply-To: <Pine.LNX.4.64.0803181137250.23639@schroedinger.engr.sgi.com>
Message-ID: <alpine.LFD.1.00.0803182113220.3020@woody.linux-foundation.org>
References: <Pine.LNX.4.64.0803171135420.8746@schroedinger.engr.sgi.com> <alpine.LFD.1.00.0803180737350.3020@woody.linux-foundation.org> <Pine.LNX.4.64.0803181037470.21992@schroedinger.engr.sgi.com> <alpine.LFD.1.00.0803181115580.3020@woody.linux-foundation.org>
 <Pine.LNX.4.64.0803181137250.23639@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>


On Tue, 18 Mar 2008, Christoph Lameter wrote:
> 
> Well it may now have become not so readable anymore. However, this 
> contains the kmalloc fallback logic in one spot. And that logic is likely 
> going to be generalized for 2.6.26 removing __PAGE_ALLOC_FALLBACK etc. The 
> chunk is going away. Either solution is fine with me. Just get it fixed.

Ok, if the code is going away, I don't care enough. I pulled your tree.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
