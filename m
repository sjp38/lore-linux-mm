Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 79E4C8D0017
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 02:28:36 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAF7SYOM016884
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 15 Nov 2010 16:28:34 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id EDFBC45DE51
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 16:28:33 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id C995145DE4E
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 16:28:33 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 757FC1DB8015
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 16:28:33 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 1EA4DE78004
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 16:28:33 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: fadvise DONTNEED implementation (or lack thereof)
In-Reply-To: <AANLkTim0vCJkMoH5P0wCN9J6340rDsscyNBQ+R+_ph8m@mail.gmail.com>
References: <20101115160413.BF0F.A69D9226@jp.fujitsu.com> <AANLkTim0vCJkMoH5P0wCN9J6340rDsscyNBQ+R+_ph8m@mail.gmail.com>
Message-Id: <20101115162713.BF12.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 15 Nov 2010 16:28:32 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Ben Gamari <bgamari.foss@gmail.com>, linux-kernel@vger.kernel.org, rsync@lists.samba.org, linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

> On Mon, Nov 15, 2010 at 4:09 PM, KOSAKI Motohiro
> <kosaki.motohiro@jp.fujitsu.com> wrote:
> >> > Because we have an alternative solution already. please try memcgroup :)
> >>
> >> I think memcg could be a solution of them but fundamental solution is
> >> that we have to cure it in VM itself.
> >> I feel it's absolutely absurd to enable and use memcg for amending it.
> >>
> >> I wonder what's the problem in Peter's patch 'drop behind'.
> >> http://www.mail-archive.com/linux-kernel@vger.kernel.org/msg179576.html
> >>
> >> Could anyone tell me why it can't accept upstream?
> >
> > I don't know the reason. And this one looks reasonable to me. I'm curious the above
> > patch solve rsync issue or not.
> > Minchan, have you tested it yourself?
> 
> Still yet. :)
> If we all think it's reasonable, it would be valuable to adjust it
> with current mmotm and see the effect.

Who can make rsync like io pattern test suite? a code change is easy. but
to comfirm justification is more harder work.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
