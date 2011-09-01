Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 356C26B016A
	for <linux-mm@kvack.org>; Thu,  1 Sep 2011 18:17:25 -0400 (EDT)
Date: Thu, 1 Sep 2011 15:16:50 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -v2 -mm] add extra free kbytes tunable
Message-Id: <20110901151650.0a82716b.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1109011501260.22550@chino.kir.corp.google.com>
References: <20110901105208.3849a8ff@annuminas.surriel.com>
	<20110901100650.6d884589.rdunlap@xenotime.net>
	<20110901152650.7a63cb8b@annuminas.surriel.com>
	<20110901145819.4031ef7c.akpm@linux-foundation.org>
	<alpine.DEB.2.00.1109011501260.22550@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Rik van Riel <riel@redhat.com>, Randy Dunlap <rdunlap@xenotime.net>, Satoru Moriya <smoriya@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, lwoodman@redhat.com, Seiji Aguchi <saguchi@redhat.com>, hughd@google.com, hannes@cmpxchg.org

On Thu, 1 Sep 2011 15:08:00 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> On Thu, 1 Sep 2011, Andrew Morton wrote:
> 
> > > Add a userspace visible knob
> > 
> > argh.  Fear and hostility at new knobs which need to be maintained for
> > ever, even if the underlying implementation changes.
> > 
> 
> Do we really need to maintain tunables that lose their purpose either 
> because the implementation changes or is patched to fix the issue that the 
> tunable was intended to address without requiring it?
> 
> Are there really userspace tools written to not be able to handle -ENOENT 
> when one of these gets removed?

I don't know, and neither does anyone else.  So we need to be cautious.
Like putting a warning printk in there and waiting several years.

And it's not just a matter of handling ENOENT.  The user modified this
tunable for a *reason*.  They were expecting some behaviour change in
the kernel.  If we remove the tunable, we take that behaviour change
away from them.  So by adding this tunable, we constrain future
implementations by requiring those implementations to automatically do
whatever the user was previously doing manually.  And we don't reliably
know *why* each user altered that tunable.  It's a horrid mess.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
