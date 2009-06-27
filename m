Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6FA236B004D
	for <linux-mm@kvack.org>; Sat, 27 Jun 2009 07:55:21 -0400 (EDT)
Date: Sat, 27 Jun 2009 13:53:07 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 0/3] make mapped executable pages the first class citizen
Message-ID: <20090627115306.GA1741@cmpxchg.org>
References: <7561.1245768237@redhat.com> <20090624023251.GA16483@localhost> <20090624114055.225D.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090624114055.225D.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, David Howells <dhowells@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, "peterz@infradead.org" <peterz@infradead.org>, "riel@redhat.com" <riel@redhat.com>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jun 24, 2009 at 11:43:21AM +0900, KOSAKI Motohiro wrote:
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

No, it has 600MB free pages after an OOM - which only means that the
OOM killer did a good job ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
