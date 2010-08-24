Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6F09560080F
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 23:03:06 -0400 (EDT)
Received: from kpbe17.cbf.corp.google.com (kpbe17.cbf.corp.google.com [172.25.105.81])
	by smtp-out.google.com with ESMTP id o7O3331M015242
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 20:03:03 -0700
Received: from gyd8 (gyd8.prod.google.com [10.243.49.200])
	by kpbe17.cbf.corp.google.com with ESMTP id o7O332JV004589
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 20:03:02 -0700
Received: by gyd8 with SMTP id 8so2598746gyd.5
        for <linux-mm@kvack.org>; Mon, 23 Aug 2010 20:03:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100824023028.GA9005@localhost>
References: <1282296689-25618-1-git-send-email-mrubin@google.com>
 <1282296689-25618-4-git-send-email-mrubin@google.com> <20100820100855.GC8440@localhost>
 <AANLkTi=+uNFq5=5gmjfAOhngXqR8RS3dX3E2uEWG33Ot@mail.gmail.com>
 <20100821004804.GA11030@localhost> <AANLkTim4NZrV18a2LYpyTz9+MSBgVw6KKo4tCUmu9GHZ@mail.gmail.com>
 <20100824023028.GA9005@localhost>
From: Michael Rubin <mrubin@google.com>
Date: Mon, 23 Aug 2010 20:02:42 -0700
Message-ID: <AANLkTi=KwJat47-7GjQOhhMnriiBE5sBOR2b9b7XC6As@mail.gmail.com>
Subject: Re: [PATCH 3/4] writeback: nr_dirtied and nr_entered_writeback in /proc/vmstat
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "jack@suse.cz" <jack@suse.cz>, "riel@redhat.com" <riel@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "david@fromorbit.com" <david@fromorbit.com>, "npiggin@kernel.dk" <npiggin@kernel.dk>, "hch@lst.de" <hch@lst.de>, "axboe@kernel.dk" <axboe@kernel.dk>
List-ID: <linux-mm.kvack.org>

On Mon, Aug 23, 2010 at 7:30 PM, Wu Fengguang <fengguang.wu@intel.com> wrote:
> It's about the interface, I don't mind you adding the per-node vmstat
> entries which may be convenient for you and mostly harmless to others.
>
> My concern is, what do you think about the existing
> /proc/<pid>/io:write_bytes interface and is it good enough for your?
> You'll have to iterate through tasks to collect numbers for one job or
> for the whole system, however that should be easy and more flexible?

Is this as an alternative to the vmstat counters or the per node
vmstat counters?

In either case I am not sure /proc/pid will be sufficient. What if 20
processes are created, write a lot of data, then quit? How do we know
about those events later? What about jobs that wake up, write data
then quit quickly?

If we are running many many tasks I would think the amount of time it
can take to cycle through all of them might mean we might not capture
all the data.

The goal is to have a complete view of the dirtying and cleaning of
the pages over time. Using /proc/pid feels like it won't achieve that.

mrubin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
