Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id E83016B0062
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 05:36:26 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBGAaOn5023231
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 16 Dec 2009 19:36:24 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 024732AEA81
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 19:36:24 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D3AEB45DE4D
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 19:36:23 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 029BF1DB8037
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 19:36:23 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 59A661DB8042
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 19:36:19 +0900 (JST)
Date: Wed, 16 Dec 2009 19:33:15 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [mm][RFC][PATCH 0/11] mm accessor updates.
Message-Id: <20091216193315.14a508d5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <28c262360912160231r18db8478sf41349362360cab8@mail.gmail.com>
References: <20091216120011.3eecfe79.kamezawa.hiroyu@jp.fujitsu.com>
	<20091216101107.GA15031@basil.fritz.box>
	<20091216191312.f4655dac.kamezawa.hiroyu@jp.fujitsu.com>
	<20091216102806.GC15031@basil.fritz.box>
	<28c262360912160231r18db8478sf41349362360cab8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andi Kleen <andi@firstfloor.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cl@linux-foundation.org, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mingo@elte.hu" <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Wed, 16 Dec 2009 19:31:40 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> On Wed, Dec 16, 2009 at 7:28 PM, Andi Kleen <andi@firstfloor.org> wrote:
> >> > Also the patches didn't fare too well in testing unfortunately.
> >> >
> >> > I suspect we'll rather need multiple locks split per address
> >> > space range.
> >>
> >> This set doesn't include any changes of the logic. Just replace all mmap_sem.
> >> I think this is good start point (for introducing another logic etc..)
> >
> > The problem is that for range locking simple wrapping the locks
> > in macros is not enough. You need more changes.
> 
> I agree.
> 
> We can't justify to merge as only this patch series although this
> doesn't change
> any behavior.
> 

> After we see the further works, let us discuss this patch's value.
> 
Ok, I'll show new version of speculative page fault.


> Nitpick:
> In case of big patch series, it would be better to provide separate
> all-at-once patch
> with convenience for easy patch and testing. :)
> 
Sure, keep it in my mind.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
