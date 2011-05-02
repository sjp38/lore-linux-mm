Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 6634D6B0012
	for <linux-mm@kvack.org>; Mon,  2 May 2011 19:58:30 -0400 (EDT)
Subject: Re: memcg: fix fatal livelock in kswapd
From: James Bottomley <James.Bottomley@suse.de>
In-Reply-To: <BANLkTikDyL9-XLpwyLwUQNuUfkBwbUBcZg@mail.gmail.com>
References: <1304366849.15370.27.camel@mulgrave.site>
	 <20110502224838.GB10278@cmpxchg.org>
	 <BANLkTikDyL9-XLpwyLwUQNuUfkBwbUBcZg@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 02 May 2011 18:58:18 -0500
Message-ID: <1304380698.15370.36.camel@mulgrave.site>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Chris Mason <chris.mason@oracle.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, containers@lists.linux-foundation.org, Balbir Singh <balbir@linux.vnet.ibm.com>

On Mon, 2011-05-02 at 16:14 -0700, Ying Han wrote:
> On Mon, May 2, 2011 at 3:48 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> > I am very much for removing this hack.  There is still more scan
> > pressure applied to memcgs in excess of their soft limit even if the
> > extra scan is happening at a sane priority level.  And the fact that
> > global reclaim operates completely unaware of memcgs is a different
> > story.
> >
> > However, this code came into place with v2.6.31-8387-g4e41695.  Why is
> > it only now showing up?
> >
> > You also wrote in that thread that this happens on a standard F15
> > installation.  On the F15 I am running here, systemd does not
> > configure memcgs, however.  Did you manually configure memcgs and set
> > soft limits?  Because I wonder how it ended up in soft limit reclaim
> > in the first place.

It doesn't ... it's standard FC15 ... the mere fact of having memcg
compiled into the kernel is enough to do it (conversely disabling it at
compile time fixes the problem).

> curious as well. if we have workload to reproduce it, i would like to try

Well, the only one I can suggest is the one that produces it (large
untar).  There seems to be something magical about the memory size (mine
is 2G) because adding more also seems to make the problem go away.

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
