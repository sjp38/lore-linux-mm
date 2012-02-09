Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 34C646B13F2
	for <linux-mm@kvack.org>; Thu,  9 Feb 2012 13:33:06 -0500 (EST)
Received: by qcsd16 with SMTP id d16so1358865qcs.14
        for <linux-mm@kvack.org>; Thu, 09 Feb 2012 10:33:05 -0800 (PST)
Date: Thu, 9 Feb 2012 19:32:59 +0100
From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: Re: [v7 0/8] Reduce cross CPU IPI interference
Message-ID: <20120209183257.GI22552@somewhere.redhat.com>
References: <1327572121-13673-1-git-send-email-gilad@benyossef.com>
 <1327591185.2446.102.camel@twins>
 <CAOtvUMeAkPzcZtiPggacMQGa0EywTH5SzcXgWjMtssR6a5KFqA@mail.gmail.com>
 <20120201170443.GE6731@somewhere.redhat.com>
 <CAOtvUMc8L1nh2eGJez0x44UkfPCqd+xYQASsKOP76atopZi5mw@mail.gmail.com>
 <20120202162420.GE9071@somewhere.redhat.com>
 <alpine.DEB.2.00.1202021028120.6221@router.home>
 <20120209155246.GD22552@somewhere.redhat.com>
 <alpine.DEB.2.00.1202091024340.32064@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1202091024340.32064@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Avi Kivity <avi@redhat.com>, Michal Nazarewicz <mina86@mina86.com>, Kosaki Motohiro <kosaki.motohiro@gmail.com>, Milton Miller <miltonm@bga.com>

On Thu, Feb 09, 2012 at 10:26:02AM -0600, Christoph Lameter wrote:
> On Thu, 9 Feb 2012, Frederic Weisbecker wrote:
> 
> > > The vmstat timer only makes sense when the OS is doing something on the
> > > processor. Otherwise if no counters are incremented and the page and slab
> > > allocator caches are empty then there is no need to run the vmstat timer.
> >
> > So this is a typical example of a timer we want to shutdown when the CPU is idle
> > but we want to keep it running when we run in adaptive tickless mode (ie: shutdown
> > the tick while the CPU is busy).
> 
> You can also shut it down when the cpu is busy and not doing any system
> calls. If the percpu differentials are all zero (because you just ran the
> timer f.e.) and there are no system activities that would change the
> counters then there is no point in running the vmstat timer.

Yep. I believe we can probably find that timer pattern elsewhere as well.
A class of userspace/idle defferable timers.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
