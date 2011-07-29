Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 0A15F6B00EE
	for <linux-mm@kvack.org>; Fri, 29 Jul 2011 11:24:49 -0400 (EDT)
Date: Fri, 29 Jul 2011 10:24:45 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [GIT PULL] SLAB changes for v3.1-rc0
In-Reply-To: <alpine.DEB.2.00.1107281514080.29344@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1107291023000.16178@router.home>
References: <alpine.DEB.2.00.1107221108190.2996@tiger> <CAOJsxLHniS9Hx+ep_i2qbE_Oo6PnkNCK5dNARW5egg9Bso4Ovg@mail.gmail.com> <alpine.DEB.2.00.1107281514080.29344@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Pekka Enberg <penberg@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 28 Jul 2011, David Rientjes wrote:

> On Thu, 28 Jul 2011, Pekka Enberg wrote:
>
> > Christoph, your debugging fix has been in linux-next for few days now
> > and no problem have been reported. I'm considering sending the series
> > to Linus. What do you think?
> >
>
> I ran slub/lockless through some stress testing and it seems to be quite
> stable on my testing cluster.  There is about a 2.3% performance
> improvement with the lockless slowpath on the netperf benchmark with
> various thread counts on my 16-core 64GB Opterons, so I'd recommend it to
> be merged into 3.1.

Great. Could you also test the next stage of patches (not yet even in
Pekka's tree) where we add a per cpu cache of partial allocated slab
pages? This decreases the per node lock contention further. I can repost
the set if the old one does not work for you. Shows significant
improvement here as well.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
