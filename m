Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id A61426B0062
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 05:34:16 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBGAYDJh021002
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 16 Dec 2009 19:34:13 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7D17745DE51
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 19:34:13 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 5E10C45DE52
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 19:34:13 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 49D221DB8043
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 19:34:13 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id F28BA1DB8038
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 19:34:12 +0900 (JST)
Date: Wed, 16 Dec 2009 19:31:09 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [mm][RFC][PATCH 0/11] mm accessor updates.
Message-Id: <20091216193109.778b881b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091216102806.GC15031@basil.fritz.box>
References: <20091216120011.3eecfe79.kamezawa.hiroyu@jp.fujitsu.com>
	<20091216101107.GA15031@basil.fritz.box>
	<20091216191312.f4655dac.kamezawa.hiroyu@jp.fujitsu.com>
	<20091216102806.GC15031@basil.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cl@linux-foundation.org, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mingo@elte.hu" <mingo@elte.hu>, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

On Wed, 16 Dec 2009 11:28:06 +0100
Andi Kleen <andi@firstfloor.org> wrote:

> > > Also the patches didn't fare too well in testing unfortunately.
> > > 
> > > I suspect we'll rather need multiple locks split per address
> > > space range.
> > 
> > This set doesn't include any changes of the logic. Just replace all mmap_sem.
> > I think this is good start point (for introducing another logic etc..)
> 
> The problem is that for range locking simple wrapping the locks
> in macros is not enough. You need more changes.
> 
maybe. but removing scatterred mmap_sem from codes is the first thing to do.
I think this removing itself will take 3 month or a half year.
(So, I didn't remove mmap_sem and leave it as it is.)

The problem of range locking is more than mmap_sem, anyway. I don't think
it's possible easily.

But ok, if no one welcome this, I stop this.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
