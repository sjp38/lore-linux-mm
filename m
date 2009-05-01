Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 87D856B003D
	for <linux-mm@kvack.org>; Fri,  1 May 2009 16:33:22 -0400 (EDT)
Date: Fri, 1 May 2009 13:28:18 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] use GFP_NOFS in kernel_event()
Message-Id: <20090501132818.b16704c4.akpm@linux-foundation.org>
In-Reply-To: <1241201494.3086.3.camel@dhcp231-142.rdu.redhat.com>
References: <20090430020004.GA1898@localhost>
	<20090429191044.b6fceae2.akpm@linux-foundation.org>
	<1241097573.6020.7.camel@localhost.localdomain>
	<20090430141041.c167b4d4.akpm@linux-foundation.org>
	<1241201494.3086.3.camel@dhcp231-142.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Eric Paris <eparis@redhat.com>
Cc: fengguang.wu@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mpm@selenic.com, clameter@sgi.com, mingo@elte.hu, viro@zeniv.linux.org.uk
List-ID: <linux-mm.kvack.org>

On Fri, 01 May 2009 14:11:34 -0400
Eric Paris <eparis@redhat.com> wrote:

> On Thu, 2009-04-30 at 14:10 -0700, Andrew Morton wrote:
> > On Thu, 30 Apr 2009 09:19:33 -0400
> > Eric Paris <eparis@redhat.com> wrote:
> > 
> > > > Somebody was going to fix this for us via lockdep annotation.
> > > > 
> > > > <adds randomly-chosen cc>
> > > 
> > > I really didn't forget this, but I can't figure out how to recreate it,
> > > so I don't know if my logic in the patch is sound.  The patch certainly
> > > will shut up the complaint.
> > 
> > Do you think we should merge the GFP_NOFS workaround for 2.6.30 and
> > fix all up nicely for 2.6.31?
> 
> I'm all for it for 2.6.30

OK.

> although the patch really should have been
> the one that gets the audit use case too at 
> 
> >From me on Mar 18 Subject [PATCH] make inotify event handles use
> GFP_NOFS
> 
> http://lkml.org/lkml/2009/3/18/310

I queued that as an incremental to Wu Fengguang's patch, because
inotify-use-gfp_nofs-in-kernel_event-to-work-around-a-lockdep-false-positive.patch
has a longer changelog ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
