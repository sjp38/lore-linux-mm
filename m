Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 40DC16B005A
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 22:48:09 -0400 (EDT)
Date: Wed, 24 Jun 2009 10:49:05 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 0/3] make mapped executable pages the first class
	citizen
Message-ID: <20090624024905.GA32094@localhost>
References: <7561.1245768237@redhat.com> <20090624023251.GA16483@localhost> <20090624114055.225D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090624114055.225D.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: David Howells <dhowells@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "peterz@infradead.org" <peterz@infradead.org>, "riel@redhat.com" <riel@redhat.com>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jun 24, 2009 at 10:43:21AM +0800, KOSAKI Motohiro wrote:
> > On Tue, Jun 23, 2009 at 10:43:57PM +0800, David Howells wrote:
> > > Wu Fengguang <fengguang.wu@intel.com> wrote:
> > > 
> > > > David, could you try running this when it occurred again?
> > > > 
> > > >         make Documentation/vm/page-types
> > > >         Documentation/vm/page-types --raw  # run as root
> > > 
> > > Okay.  I managed to catch it between the first and second OOMs, and ran the
> > > command you asked for.
> > 
> > Thank you!
> > 
> > > 0x0000000000000000	    142261      555  ________________________________	
> > > 0x0000000000000400	      6797       26  __________B_____________________	buddy
> > 
> > The buddy+free numbers are pretty high. 26MB PG_buddy pages means much
> > more actual free pages. So I bet the 555MB no-flag pages are mostly free pages.
> 
> You mean our VM can make OOM although it have 600MB free pages?

Not exactly from one of the previous OOM messages:

DMA: 1*4kB 1*8kB 0*16kB 0*32kB 1*64kB 0*128kB 1*256kB 1*512kB 1*1024kB 1*2048kB 0*4096kB = 3916kB
DMA32: 576*4kB 15*8kB 1*16kB 0*32kB 1*64kB 0*128kB 1*256kB 1*512kB 1*1024kB 0*2048kB 0*4096kB = 4296kB

It looks like something goes wrong with the buddy system?

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
