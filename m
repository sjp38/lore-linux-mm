Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 8A09B6B0044
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 06:15:38 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBGBFZud004970
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 16 Dec 2009 20:15:35 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6810E45DE50
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 20:15:35 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4666945DE4E
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 20:15:35 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2E6641DB803C
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 20:15:35 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id DD1451DB803A
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 20:15:31 +0900 (JST)
Date: Wed, 16 Dec 2009 20:12:18 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [mm][RFC][PATCH 0/11] mm accessor updates.
Message-Id: <20091216201218.42ff7f05.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091216104951.GD15031@basil.fritz.box>
References: <20091216120011.3eecfe79.kamezawa.hiroyu@jp.fujitsu.com>
	<20091216101107.GA15031@basil.fritz.box>
	<20091216191312.f4655dac.kamezawa.hiroyu@jp.fujitsu.com>
	<20091216102806.GC15031@basil.fritz.box>
	<20091216193109.778b881b.kamezawa.hiroyu@jp.fujitsu.com>
	<20091216104951.GD15031@basil.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cl@linux-foundation.org, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mingo@elte.hu" <mingo@elte.hu>, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

On Wed, 16 Dec 2009 11:49:51 +0100
Andi Kleen <andi@firstfloor.org> wrote:

> On Wed, Dec 16, 2009 at 07:31:09PM +0900, KAMEZAWA Hiroyuki wrote:
> > On Wed, 16 Dec 2009 11:28:06 +0100
> > Andi Kleen <andi@firstfloor.org> wrote:
> > 
> > > > > Also the patches didn't fare too well in testing unfortunately.
> > > > > 
> > > > > I suspect we'll rather need multiple locks split per address
> > > > > space range.
> > > > 
> > > > This set doesn't include any changes of the logic. Just replace all mmap_sem.
> > > > I think this is good start point (for introducing another logic etc..)
> > > 
> > > The problem is that for range locking simple wrapping the locks
> > > in macros is not enough. You need more changes.
> > > 
> > maybe. but removing scatterred mmap_sem from codes is the first thing to do.
> > I think this removing itself will take 3 month or a half year.
> > (So, I didn't remove mmap_sem and leave it as it is.)
> 
> I suspect you would just need to change them again then.
> 
Do you have alternative recommendation rather than wrapping all accesses by
special functions ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
