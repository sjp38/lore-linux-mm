Date: Mon, 30 Oct 2000 10:02:15 +0100
From: G?bor L?n?rt <lgb@viva.uti.hu>
Subject: Re: Discussion on my OOM killer API
Message-ID: <20001030100215.A26676@viva.uti.hu>
References: <Pine.LNX.4.10.10010271832020.13084-100000@dax.joh.cam.ac.uk> <20001027221259.C0ED4F42C@agnes.fremen.dune>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20001027221259.C0ED4F42C@agnes.fremen.dune>; from jfm2@club-internet.fr on Sat, Oct 28, 2000 at 12:12:59AM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Oct 28, 2000 at 12:12:59AM +0200, jfm2@club-internet.fr wrote:
> > > echo "my-kewl-oom-killer" >/proc/sys/vm/oom_handler
> > > 
> > > will try to load the module with this name for a new one and
> > > uninstall the old one.
> > 
> > EBADIDEA. The kernel's OOM killer is a last ditch "something's going to
> > die - who's first?" - adding extra bloat like this is BAD.

Yep.

> > Policy should be decided user-side, and should prevent the kernel-side
> > killer EVER triggering.
> > 
> 
> Only problem is that your user side process will have been pushed out
> of memory by netcape and that in this kind of situations it will take
> a looooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooong

Nope. Use mlock().
Second it's clear that we should implement a stupid kernel side OOM killer
too in case of something goes really wrong, but that killer can be really
stupid and constant part of system. In normal cases user space OOM killer
should do the job for us ...

- Gabor
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
