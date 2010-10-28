Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8D1678D0015
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 09:50:52 -0400 (EDT)
Date: Thu, 28 Oct 2010 15:50:38 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: 2.6.36 io bring the system to its knees
Message-ID: <20101028135038.GA32157@elte.hu>
References: <AANLkTimt7wzR9RwGWbvhiOmot_zzayfCfSh_-v6yvuAP@mail.gmail.com>
 <AANLkTikRKVBzO=ruy=JDmBF28NiUdJmAqb4-1VhK0QBX@mail.gmail.com>
 <AANLkTinzJ9a+9w7G5X0uZpX2o-L8E6XW98VFKoF1R_-S@mail.gmail.com>
 <AANLkTinDDG0ZkNFJZXuV9k3nJgueUW=ph8AuHgyeAXji@mail.gmail.com>
 <AANLkTikvSGNE7uGn5p0tfJNg4Hz5WRmLRC8cXu7+GhMk@mail.gmail.com>
 <20101028090002.GA12446@elte.hu>
 <AANLkTinoGGLTN2JRwjJtF6Ra5auZVg+VSa=TyrtAkDor@mail.gmail.com>
 <20101028133036.GA30565@elte.hu>
 <20101028134724.GB4416@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101028134724.GB4416@infradead.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Pekka Enberg <penberg@kernel.org>, Aidar Kultayev <the.aidar@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <npiggin@suse.de>, Arjan van de Ven <arjan@infradead.org>, Thomas Gleixner <tglx@linutronix.de>
List-ID: <linux-mm.kvack.org>


* Christoph Hellwig <hch@infradead.org> wrote:

> On Thu, Oct 28, 2010 at 03:30:36PM +0200, Ingo Molnar wrote:
> > > Looks mostly VFS to me. Aidar, does killing Picasa make things smoother for you? 
> > > If so, maybe the VFS scalability patches will help.
> > 
> > Hm, but the VFS scalability patches mostly decrease CPU usage, and does that 
> > mostly on many-core systems.
> 
> If you have i_mutex contention they are not going to change anything.

Yes, that was my point.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
