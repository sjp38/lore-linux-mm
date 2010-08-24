Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 8554B60080F
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 23:26:42 -0400 (EDT)
Date: Tue, 24 Aug 2010 11:25:34 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 3/4] writeback: nr_dirtied and nr_entered_writeback in
 /proc/vmstat
Message-ID: <20100824032534.GC11970@localhost>
References: <1282296689-25618-1-git-send-email-mrubin@google.com>
 <1282296689-25618-4-git-send-email-mrubin@google.com>
 <20100820100855.GC8440@localhost>
 <AANLkTi=+uNFq5=5gmjfAOhngXqR8RS3dX3E2uEWG33Ot@mail.gmail.com>
 <20100821004804.GA11030@localhost>
 <AANLkTim4NZrV18a2LYpyTz9+MSBgVw6KKo4tCUmu9GHZ@mail.gmail.com>
 <20100824023028.GA9005@localhost>
 <AANLkTi=KwJat47-7GjQOhhMnriiBE5sBOR2b9b7XC6As@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTi=KwJat47-7GjQOhhMnriiBE5sBOR2b9b7XC6As@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Michael Rubin <mrubin@google.com>
Cc: Shailabh Nagar <nagar@watson.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "jack@suse.cz" <jack@suse.cz>, "riel@redhat.com" <riel@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "david@fromorbit.com" <david@fromorbit.com>, "npiggin@kernel.dk" <npiggin@kernel.dk>, "hch@lst.de" <hch@lst.de>, "axboe@kernel.dk" <axboe@kernel.dk>
List-ID: <linux-mm.kvack.org>

On Tue, Aug 24, 2010 at 11:02:42AM +0800, Michael Rubin wrote:
> On Mon, Aug 23, 2010 at 7:30 PM, Wu Fengguang <fengguang.wu@intel.com> wrote:
> > It's about the interface, I don't mind you adding the per-node vmstat
> > entries which may be convenient for you and mostly harmless to others.
> >
> > My concern is, what do you think about the existing
> > /proc/<pid>/io:write_bytes interface and is it good enough for your?
> > You'll have to iterate through tasks to collect numbers for one job or
> > for the whole system, however that should be easy and more flexible?
> 
> Is this as an alternative to the vmstat counters or the per node
> vmstat counters?
> 
> In either case I am not sure /proc/pid will be sufficient. What if 20
> processes are created, write a lot of data, then quit? How do we know
> about those events later? What about jobs that wake up, write data
> then quit quickly?

According to Documentation/accounting/taskstats.txt, it's possible to
register a task for collecting its stat numbers when it quits. However
I'm not sure if there are reliable ways to do this if tasks come and
go very quickly. It may help to somehow automatically add the numbers
to the parent process at process quit time.

> If we are running many many tasks I would think the amount of time it
> can take to cycle through all of them might mean we might not capture
> all the data.

Yes, 10k tasks may be too much to track.

> The goal is to have a complete view of the dirtying and cleaning of
> the pages over time. Using /proc/pid feels like it won't achieve that.

Looks so.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
