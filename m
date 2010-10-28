Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7A2048D0015
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 09:54:59 -0400 (EDT)
Date: Thu, 28 Oct 2010 15:54:45 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: 2.6.36 io bring the system to its knees
Message-ID: <20101028135445.GB32157@elte.hu>
References: <AANLkTimt7wzR9RwGWbvhiOmot_zzayfCfSh_-v6yvuAP@mail.gmail.com>
 <AANLkTikRKVBzO=ruy=JDmBF28NiUdJmAqb4-1VhK0QBX@mail.gmail.com>
 <AANLkTinzJ9a+9w7G5X0uZpX2o-L8E6XW98VFKoF1R_-S@mail.gmail.com>
 <AANLkTinDDG0ZkNFJZXuV9k3nJgueUW=ph8AuHgyeAXji@mail.gmail.com>
 <AANLkTikvSGNE7uGn5p0tfJNg4Hz5WRmLRC8cXu7+GhMk@mail.gmail.com>
 <20101028090002.GA12446@elte.hu>
 <AANLkTinoGGLTN2JRwjJtF6Ra5auZVg+VSa=TyrtAkDor@mail.gmail.com>
 <AANLkTikyYQk1FH7d6jkw2GYHLN8jmghuGZQw=EFVgjuA@mail.gmail.com>
 <AANLkTikx4zZwMLiAUrGKcH6yoo_PGgRA7nT9BzYMxQ89@mail.gmail.com>
 <20101028134641.GA4416@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101028134641.GA4416@infradead.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Pekka Enberg <penberg@kernel.org>, Aidar Kultayev <the.aidar@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, npiggin@kernel.dk, Dave Chinner <david@fromorbit.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>


* Christoph Hellwig <hch@infradead.org> wrote:

> On Thu, Oct 28, 2010 at 02:48:20PM +0300, Pekka Enberg wrote:
> > On Thu, Oct 28, 2010 at 2:33 PM, Aidar Kultayev <the.aidar@gmail.com> wrote:
> > >
> > > if it wasn't picasa, it would have been something else. I mean if I kill 
> > > picasa ( later on it was done indexing new pics anyway ), it would have been 
> > > for virtualbox to thrash the io. So, nope, getting rid of picasa doesn't help 
> > > either. In general the systems responsiveness or sluggishness is dominated by 
> > > those io operations going on - the DD & CP & probably VBOX issuing whole bunch 
> > > of its load for IO.
> > 
> > Do you still see high latencies in vfs_lseek() and vfs_fsync()? I'm not a VFS 
> > expert but looking at your latencytop output, it seems that fsync grabs 
> > ->i_mutex which blocks vfs_llseek(), for example. I'm not sure why that causes 
> > high latencies though it's a mutex we're holding.
> 
> It does.  But what workload does a lot of llseeks while fsyncing the same file?  
> I'd bet some application is doing really stupid things here.

Seeking in a file and fsync-ing it does not seem like an inherently bad or even 
stupid thing to do - why do you claim that it is stupid?

If mixed seek()+fsync() is the reason for these latencies (which is just an 
assumption right now) then it needs to be fixed in the kernel, not in apps.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
