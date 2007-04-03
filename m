Date: Tue, 3 Apr 2007 10:36:27 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [xfs-masters] Re: [PATCH] Cleanup and kernelify shrinker
 registration (rc5-mm2)
Message-Id: <20070403103627.de831e3e.akpm@linux-foundation.org>
In-Reply-To: <20070403123706.GX32597093@melbourne.sgi.com>
References: <1175571885.12230.473.camel@localhost.localdomain>
	<20070402205825.12190e52.akpm@linux-foundation.org>
	<1175575503.12230.484.camel@localhost.localdomain>
	<20070402215702.6e3782a9.akpm@linux-foundation.org>
	<1175579225.12230.504.camel@localhost.localdomain>
	<20070402230954.27840721.akpm@linux-foundation.org>
	<1175584705.12230.513.camel@localhost.localdomain>
	<20070403123706.GX32597093@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Chinner <dgc@sgi.com>
Cc: xfs-masters@oss.sgi.com, lkml - Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, reiserfs-dev@namesys.com
List-ID: <linux-mm.kvack.org>

On Tue, 3 Apr 2007 22:37:06 +1000 David Chinner <dgc@sgi.com> wrote:

> On Tue, Apr 03, 2007 at 05:18:25PM +1000, Rusty Russell wrote:
> > On Mon, 2007-04-02 at 23:09 -0700, Andrew Morton wrote:
> > This is not about efficiency.  When have I *ever* posted optimization
> > patches?
> > 
> > This is about clarity.  We have a standard convention for
> > register/unregister.  And they can't fail.  Either of these would be
> > sufficient to justify a change.
> > 
> > Too many people doing cool new things in the kernel, not enough
> > polishing of the crap that's already there 8(
> > 
> > > But I think we need to weed that crappiness out of XFS first.
> 
> Can anyone else see the contradiction in these statements?
> 
> XFS's "crappiness" is a register/unregister interface.  The only
> reason it's being removed is because it's getting replaced with a
> nearly identical register/unregister interface.

Nope.  XFS is introducing two new typedefs, one of which is identical to
one which we already have and it has wrapper functions which do little more
than add new names for existing stuff.

What Rusty is doing is changing the API so that the caller registers a
caller-owned struct rather than registering a caller-provided function. 
For some reason.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
