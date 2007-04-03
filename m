Subject: Re: [PATCH] Cleanup and kernelify shrinker registration (rc5-mm2)
From: Rusty Russell <rusty@rustcorp.com.au>
In-Reply-To: <20070402230954.27840721.akpm@linux-foundation.org>
References: <1175571885.12230.473.camel@localhost.localdomain>
	 <20070402205825.12190e52.akpm@linux-foundation.org>
	 <1175575503.12230.484.camel@localhost.localdomain>
	 <20070402215702.6e3782a9.akpm@linux-foundation.org>
	 <1175579225.12230.504.camel@localhost.localdomain>
	 <20070402230954.27840721.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Tue, 03 Apr 2007 17:18:25 +1000
Message-Id: <1175584705.12230.513.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: lkml - Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, xfs-masters@oss.sgi.com, reiserfs-dev@namesys.com
List-ID: <linux-mm.kvack.org>

On Mon, 2007-04-02 at 23:09 -0700, Andrew Morton wrote:
> hm, well, six-of-one, VI of the other.  We save maybe four kmallocs across
> the entire uptime at the cost of exposing stuff kernel-side which doesn't
> need to be exposed.

This is not about efficiency.  When have I *ever* posted optimization
patches?

This is about clarity.  We have a standard convention for
register/unregister.  And they can't fail.  Either of these would be
sufficient to justify a change.

Too many people doing cool new things in the kernel, not enough
polishing of the crap that's already there 8(

> But I think we need to weed that crappiness out of XFS first.

Sure, I'll apply on top of that patch.

Thanks!
Rusty.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
