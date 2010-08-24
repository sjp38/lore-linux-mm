Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6D5F260080F
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 22:42:44 -0400 (EDT)
Received: from kpbe18.cbf.corp.google.com (kpbe18.cbf.corp.google.com [172.25.105.82])
	by smtp-out.google.com with ESMTP id o7O2gfQH012412
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 19:42:41 -0700
Received: from ywg4 (ywg4.prod.google.com [10.192.7.4])
	by kpbe18.cbf.corp.google.com with ESMTP id o7O2gerL029602
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 19:42:40 -0700
Received: by ywg4 with SMTP id 4so2958530ywg.7
        for <linux-mm@kvack.org>; Mon, 23 Aug 2010 19:42:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100824021136.GA9254@localhost>
References: <20100821054808.GA29869@localhost> <AANLkTikS+DUfPz0E2SmCZTQBWL8h2zSsGM8--yqEaVgZ@mail.gmail.com>
 <20100824100943.F3B6.A69D9226@jp.fujitsu.com> <AANLkTi=OwGUzM0oZ5qTEFnGTuo8kVfW79oqH-Dcf8jdp@mail.gmail.com>
 <20100824021136.GA9254@localhost>
From: Michael Rubin <mrubin@google.com>
Date: Mon, 23 Aug 2010 19:42:20 -0700
Message-ID: <AANLkTikcsqnwwNjXPPTJ3xb981Z0hopWRLEYjrE3uvQ7@mail.gmail.com>
Subject: Re: [PATCH 4/4] writeback: Reporting dirty thresholds in /proc/vmstat
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "jack@suse.cz" <jack@suse.cz>, "riel@redhat.com" <riel@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "david@fromorbit.com" <david@fromorbit.com>, "npiggin@kernel.dk" <npiggin@kernel.dk>, "hch@lst.de" <hch@lst.de>, "axboe@kernel.dk" <axboe@kernel.dk>
List-ID: <linux-mm.kvack.org>

On Mon, Aug 23, 2010 at 7:11 PM, Wu Fengguang <fengguang.wu@intel.com> wrot=
e:
> Sorry for giving a wrong example. Hope this one is better:
>
> $ cat /debug/bdi/default/stats
> [...]
> DirtyThresh: =A0 =A0 =A0 1838904 kB
> BackgroundThresh: =A0 919452 kB
> [...]
>
> It's a trick to avoid messing with real devices :)

That's cool. And it's the exact code path :-)

mrubin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
