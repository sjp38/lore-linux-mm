Received: from CONVERSION-DAEMON.jhuml3.jhu.edu by jhuml3.jhu.edu
 (PMDF V6.0-24 #47562) id <0GK800G01BWJN9@jhuml3.jhu.edu> for
 linux-mm@kvack.org; Tue, 25 Sep 2001 13:43:31 -0400 (EDT)
Received: from aa.eps.jhu.edu (aa.eps.jhu.edu [128.220.24.92])
 by jhuml3.jhu.edu (PMDF V6.0-24 #47562)
 with ESMTP id <0GK800G6KBWJBD@jhuml3.jhu.edu> for linux-mm@kvack.org; Tue,
 25 Sep 2001 13:43:31 -0400 (EDT)
Date: Tue, 25 Sep 2001 13:36:51 -0400 (EDT)
From: afei@jhu.edu
Subject: Re: Process not given >890MB on a 4MB machine ?????????
In-reply-to: <20010925115914.F3437@redhat.com>
Message-id: <Pine.GSO.4.05.10109251335380.23459-100000@aa.eps.jhu.edu>
MIME-version: 1.0
Content-type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Joseph A Knapka <jknapka@earthlink.net>, "Gabriel.Leen" <Gabriel.Leen@ul.ie>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

The current Linux MM design is a 3:1 split of 4G virtual/physical memory.
So a process, under normal condition cannot get beyond 3G memory
allocated.

On Tue, 25 Sep 2001, Stephen C. Tweedie wrote:

> Hi,
>
> On Mon, Sep 24, 2001 at 09:16:58PM +0000, Joseph A Knapka wrote:
>
> > No. You still only get a maximum of 4GB of -virtual- space per
> > process. The machine can address up to 64GB of -physical- RAM,
> > but a single process (actually a single page directory) can
> > see only 4GB at a time. Sorry :-(
>
> There are hacks to work around this --- for example, you can set up
> large amounts of shared memory and map that on demand when you are
> looking up your dataset.  However, it's simply not possible for user
> space to refer to more than 3GB at once on Linux/Intel.  You *must* go
> to a 64-bit architecture if you want more than that.
>
> Cheers,
>  Stephen
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
