Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id A85816B008C
	for <linux-mm@kvack.org>; Wed, 20 May 2009 10:56:04 -0400 (EDT)
Date: Wed, 20 May 2009 22:56:08 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 2/3] vmscan: make mapped executable pages the first
	class citizen
Message-ID: <20090520145607.GA6281@localhost>
References: <alpine.DEB.1.10.0905181045340.20244@qirst.com> <20090519032759.GA7608@localhost> <20090519133422.4ECC.A69D9226@jp.fujitsu.com> <20090519062503.GA9580@localhost> <87pre4nhqf.fsf@basil.nowhere.org> <20090520143258.GA5706@localhost> <20090520144731.GB4753@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090520144731.GB4753@basil.nowhere.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Elladan <elladan@eskimo.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Wed, May 20, 2009 at 10:47:31PM +0800, Andi Kleen wrote:
> > > One scenario that might be useful to test is what happens when some
> > > very large processes, all mapped and executable exceed memory and
> > 
> > Good idea. Too bad I may have to install some bloated desktop in order
> > to test this out ;) I guess the pgmajfault+pswpin numbers can serve as
> > negative scores in that case?
> 
> I would just generate a large C program with a script and compile
> and run that. The program can be very dumb (e.g. only run
> a gigantic loop), it just needs to be large.
> 
> Just don't compile it with optimization, that can be quite slow.
> 
> And use multiple functions, otherwise gcc might exceed your memory.


Hehe, an arbitrary C program may not be persuasive..but I do have some
bloated binaries at hand :-)

-rwsr-sr-x 1 root wfg   36M 2009-04-22 17:21 Xorg
lrwxrwxrwx 1 wfg  wfg     4 2009-04-22 17:21 X -> Xorg
-rwxr-xr-x 1 wfg  wfg   39M 2009-04-22 17:21 Xvfb
-rwxr-xr-x 1 wfg  wfg   35M 2009-04-22 17:21 Xnest

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
