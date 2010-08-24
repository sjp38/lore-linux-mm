Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 4063760080F
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 22:30:48 -0400 (EDT)
Date: Tue, 24 Aug 2010 10:30:28 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 3/4] writeback: nr_dirtied and nr_entered_writeback in
 /proc/vmstat
Message-ID: <20100824023028.GA9005@localhost>
References: <1282296689-25618-1-git-send-email-mrubin@google.com>
 <1282296689-25618-4-git-send-email-mrubin@google.com>
 <20100820100855.GC8440@localhost>
 <AANLkTi=+uNFq5=5gmjfAOhngXqR8RS3dX3E2uEWG33Ot@mail.gmail.com>
 <20100821004804.GA11030@localhost>
 <AANLkTim4NZrV18a2LYpyTz9+MSBgVw6KKo4tCUmu9GHZ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTim4NZrV18a2LYpyTz9+MSBgVw6KKo4tCUmu9GHZ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Michael Rubin <mrubin@google.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "jack@suse.cz" <jack@suse.cz>, "riel@redhat.com" <riel@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "david@fromorbit.com" <david@fromorbit.com>, "npiggin@kernel.dk" <npiggin@kernel.dk>, "hch@lst.de" <hch@lst.de>, "axboe@kernel.dk" <axboe@kernel.dk>
List-ID: <linux-mm.kvack.org>

On Tue, Aug 24, 2010 at 01:45:41AM +0800, Michael Rubin wrote:
> On Fri, Aug 20, 2010 at 5:48 PM, Wu Fengguang <fengguang.wu@intel.com> wrote:
> > I wonder if you'll still stick to the fake NUMA scenario two years
> > later -- when memcg grows powerful enough. What do we do then? "Hey
> > let's rip these counters, their major consumer has dumped them.."
> 
> I think the counters will still be useful for NUMA also. Is there a
> performance hit here I am missing to having the per node counters?
> Just want to make sure we are only wondering about whether or not we
> are polluting the interface? Also since we plan to change the name to
> vmstat instead doesn't that make it more generic in the future?

It's about the interface, I don't mind you adding the per-node vmstat
entries which may be convenient for you and mostly harmless to others.

My concern is, what do you think about the existing
/proc/<pid>/io:write_bytes interface and is it good enough for your?
You'll have to iterate through tasks to collect numbers for one job or
for the whole system, however that should be easy and more flexible?

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
