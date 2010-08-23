Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 43D8A6007EE
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 13:46:07 -0400 (EDT)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id o7NHk3VX029695
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 10:46:04 -0700
Received: from gxk27 (gxk27.prod.google.com [10.202.11.27])
	by wpaz17.hot.corp.google.com with ESMTP id o7NHiM1C002465
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 10:46:02 -0700
Received: by gxk27 with SMTP id 27so2655181gxk.36
        for <linux-mm@kvack.org>; Mon, 23 Aug 2010 10:46:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100821004804.GA11030@localhost>
References: <1282296689-25618-1-git-send-email-mrubin@google.com>
 <1282296689-25618-4-git-send-email-mrubin@google.com> <20100820100855.GC8440@localhost>
 <AANLkTi=+uNFq5=5gmjfAOhngXqR8RS3dX3E2uEWG33Ot@mail.gmail.com> <20100821004804.GA11030@localhost>
From: Michael Rubin <mrubin@google.com>
Date: Mon, 23 Aug 2010 10:45:41 -0700
Message-ID: <AANLkTim4NZrV18a2LYpyTz9+MSBgVw6KKo4tCUmu9GHZ@mail.gmail.com>
Subject: Re: [PATCH 3/4] writeback: nr_dirtied and nr_entered_writeback in /proc/vmstat
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "jack@suse.cz" <jack@suse.cz>, "riel@redhat.com" <riel@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "david@fromorbit.com" <david@fromorbit.com>, "npiggin@kernel.dk" <npiggin@kernel.dk>, "hch@lst.de" <hch@lst.de>, "axboe@kernel.dk" <axboe@kernel.dk>
List-ID: <linux-mm.kvack.org>

On Fri, Aug 20, 2010 at 5:48 PM, Wu Fengguang <fengguang.wu@intel.com> wrote:
> I wonder if you'll still stick to the fake NUMA scenario two years
> later -- when memcg grows powerful enough. What do we do then? "Hey
> let's rip these counters, their major consumer has dumped them.."

I think the counters will still be useful for NUMA also. Is there a
performance hit here I am missing to having the per node counters?
Just want to make sure we are only wondering about whether or not we
are polluting the interface? Also since we plan to change the name to
vmstat instead doesn't that make it more generic in the future?

mrubin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
