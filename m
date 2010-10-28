Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id F25608D0015
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 09:47:54 -0400 (EDT)
Date: Thu, 28 Oct 2010 09:46:41 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: 2.6.36 io bring the system to its knees
Message-ID: <20101028134641.GA4416@infradead.org>
References: <AANLkTimt7wzR9RwGWbvhiOmot_zzayfCfSh_-v6yvuAP@mail.gmail.com>
 <AANLkTikRKVBzO=ruy=JDmBF28NiUdJmAqb4-1VhK0QBX@mail.gmail.com>
 <AANLkTinzJ9a+9w7G5X0uZpX2o-L8E6XW98VFKoF1R_-S@mail.gmail.com>
 <AANLkTinDDG0ZkNFJZXuV9k3nJgueUW=ph8AuHgyeAXji@mail.gmail.com>
 <AANLkTikvSGNE7uGn5p0tfJNg4Hz5WRmLRC8cXu7+GhMk@mail.gmail.com>
 <20101028090002.GA12446@elte.hu>
 <AANLkTinoGGLTN2JRwjJtF6Ra5auZVg+VSa=TyrtAkDor@mail.gmail.com>
 <AANLkTikyYQk1FH7d6jkw2GYHLN8jmghuGZQw=EFVgjuA@mail.gmail.com>
 <AANLkTikx4zZwMLiAUrGKcH6yoo_PGgRA7nT9BzYMxQ89@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTikx4zZwMLiAUrGKcH6yoo_PGgRA7nT9BzYMxQ89@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@kernel.org>
Cc: Aidar Kultayev <the.aidar@gmail.com>, Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, npiggin@kernel.dk, Dave Chinner <david@fromorbit.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Oct 28, 2010 at 02:48:20PM +0300, Pekka Enberg wrote:
> On Thu, Oct 28, 2010 at 2:33 PM, Aidar Kultayev <the.aidar@gmail.com> wrote:
> > if it wasn't picasa, it would have been something else. I mean if I
> > kill picasa ( later on it was done indexing new pics anyway ), it
> > would have been for virtualbox to thrash the io. So, nope, getting rid
> > of picasa doesn't help either. In general the systems responsiveness
> > or sluggishness is dominated by those io operations going on - the DD
> > & CP & probably VBOX issuing whole bunch of its load for IO.
> 
> Do you still see high latencies in vfs_lseek() and vfs_fsync()? I'm
> not a VFS expert but looking at your latencytop output, it seems that
> fsync grabs ->i_mutex which blocks vfs_llseek(), for example. I'm not
> sure why that causes high latencies though it's a mutex we're holding.

It does.  But what workload does a lot of llseeks while fsyncing the
same file?  I'd bet some application is doing really stupid things here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
