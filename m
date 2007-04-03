Date: Mon, 2 Apr 2007 20:58:25 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Cleanup and kernelify shrinker registration (rc5-mm2)
Message-Id: <20070402205825.12190e52.akpm@linux-foundation.org>
In-Reply-To: <1175571885.12230.473.camel@localhost.localdomain>
References: <1175571885.12230.473.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: lkml - Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, xfs-masters@oss.sgi.com, reiserfs-dev@namesys.com
List-ID: <linux-mm.kvack.org>

On Tue, 03 Apr 2007 13:44:45 +1000 Rusty Russell <rusty@rustcorp.com.au> wrote:

> 
> I can never remember what the function to register to receive VM pressure
> is called.  I have to trace down from __alloc_pages() to find it.
> 
> It's called "set_shrinker()", and it needs Your Help.
> 
> New version:
> 1) Don't hide struct shrinker.  It contains no magic.
> 2) Don't allocate "struct shrinker".  It's not helpful.
> 3) Call them "register_shrinker" and "unregister_shrinker".
> 4) Call the function "shrink" not "shrinker".
> 5) Rename "nr_to_scan" argument to "nr_to_free".

No, it is actually the number to scan.  This is >= the number of freed
objects.

This is because, for better of for worse, the VM tries to balance the
scanning rate of the various caches, not the reclaiming rate.

> 6) Reduce the 17 lines of waffly comments to 10, and document the -1 return.
> 
> Comments:
> 1) The comment in reiserfs4 makes me a little queasy.

I'm going to have to split this patch up into mainline-bit and reiser4-bit.

And that's OK (it's a regular occurrence).  But never miss a chance to whine.

> 2) The wrapper code in xfs might no longer be needed.
> 3) The placing in the x86-64 "hot function list" for seems a little
>    unlikely.  Clearly, Andi was testing if anyone was paying attention.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
