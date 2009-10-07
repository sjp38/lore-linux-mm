Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id DF0AC6B0082
	for <linux-mm@kvack.org>; Wed,  7 Oct 2009 16:47:23 -0400 (EDT)
Date: Wed, 7 Oct 2009 22:47:18 +0200
From: Gleb Natapov <gleb@redhat.com>
Subject: Re: [PATCH][RFC] add MAP_UNLOCKED mmap flag
Message-ID: <20091007204718.GD19692@redhat.com>
References: <20091006190938.126F.A69D9226@jp.fujitsu.com>
 <20091006102136.GH9832@redhat.com>
 <20091006192454.1272.A69D9226@jp.fujitsu.com>
 <20091006103300.GI9832@redhat.com>
 <2f11576a0910060510y401c1d5ax6f17135478d22899@mail.gmail.com>
 <20091006121603.GK9832@redhat.com>
 <20091007185054.GB66690@dspnet.fr.eu.org>
 <20091007185952.GC19692@redhat.com>
 <20091007201017.GC66690@dspnet.fr.eu.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091007201017.GC66690@dspnet.fr.eu.org>
Sender: owner-linux-mm@kvack.org
To: Olivier Galibert <galibert@pobox.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Oct 07, 2009 at 10:10:17PM +0200, Olivier Galibert wrote:
> On Wed, Oct 07, 2009 at 08:59:52PM +0200, Gleb Natapov wrote:
> > On Wed, Oct 07, 2009 at 08:50:54PM +0200, Olivier Galibert wrote:
> > > On Tue, Oct 06, 2009 at 02:16:03PM +0200, Gleb Natapov wrote:
> > > > I did. It allows me to achieve something I can't now. Steps you provide
> > > > just don't fit my needs. I need all memory areas (current and feature) to be
> > > > locked except one. Very big one. You propose to lock memory at some
> > > > arbitrary point and from that point on all newly mapped memory areas will
> > > > be unlocked. Don't you see it is different?
> > > 
> > > What about mlockall(MCL_CURRENT); mmap(...); mlockall(MCL_FUTURE);?
> > > Or toggle MCL_FUTURE if a mlockall call can stop it?
> > > 
> > This may work. And MCL_FUTURE can be toggled, but this is not thread
> > safe.
> 
> Just ensure that your one special mmap is done with the other threads
> not currently allocating stuff.  It's probably a synchronization point
> for the whole process anyway.
> 
How can you stop other threads and libraries from calling malloc()? And if
it is two special allocations? Or many mmap(big file)/munmap(big file)?
This is the same issue as opening file CLOEXEC atomically. Why not
prevent other thread from calling fork() instead of adding flags to
bunch of system calls.

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
