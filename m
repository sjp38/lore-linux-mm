Subject: Re: [PATCH] Cleanup and kernelify shrinker registration (rc5-mm2)
From: Rusty Russell <rusty@rustcorp.com.au>
In-Reply-To: <20070402205825.12190e52.akpm@linux-foundation.org>
References: <1175571885.12230.473.camel@localhost.localdomain>
	 <20070402205825.12190e52.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Tue, 03 Apr 2007 14:45:02 +1000
Message-Id: <1175575503.12230.484.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: lkml - Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, xfs-masters@oss.sgi.com, reiserfs-dev@namesys.com
List-ID: <linux-mm.kvack.org>

On Mon, 2007-04-02 at 20:58 -0700, Andrew Morton wrote:
> On Tue, 03 Apr 2007 13:44:45 +1000 Rusty Russell <rusty@rustcorp.com.au> wrote:
> 
> > 
> > I can never remember what the function to register to receive VM pressure
> > is called.  I have to trace down from __alloc_pages() to find it.
> > 
> > It's called "set_shrinker()", and it needs Your Help.
> > 
> > New version:
> > 1) Don't hide struct shrinker.  It contains no magic.
> > 2) Don't allocate "struct shrinker".  It's not helpful.
> > 3) Call them "register_shrinker" and "unregister_shrinker".
> > 4) Call the function "shrink" not "shrinker".
> > 5) Rename "nr_to_scan" argument to "nr_to_free".
> 
> No, it is actually the number to scan.  This is >= the number of freed
> objects.
> 
> This is because, for better of for worse, the VM tries to balance the
> scanning rate of the various caches, not the reclaiming rate.

Err, ok, I completely missed that distinction.

Does that mean the to function correctly every user needs some internal
cursor so it doesn't end up scanning the first N entries over and over?

Rusty.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
