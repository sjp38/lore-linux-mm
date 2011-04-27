Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id C4FB09000C1
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 22:06:49 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 6DE313EE0C1
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 11:06:46 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5466745DE50
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 11:06:46 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3DD2A45DE4D
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 11:06:46 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 27523E78003
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 11:06:46 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id DB6C1E78002
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 11:06:45 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH v2] virtio_balloon: disable oom killer when fill balloon
In-Reply-To: <BANLkTikfyi2FBykk1D1H-tdrSjmRYEh6ug@mail.gmail.com>
References: <BANLkTi=8ySUPP6_GUL9CTFh98J1PH0a4=g@mail.gmail.com> <BANLkTikfyi2FBykk1D1H-tdrSjmRYEh6ug@mail.gmail.com>
Message-Id: <20110427110838.D178.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Wed, 27 Apr 2011 11:06:45 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Young <hidave.darkstar@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Minchan Kim <minchan.kim@gmail.com>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

> On Wed, Apr 27, 2011 at 9:37 AM, Dave Young <hidave.darkstar@gmail.com> wrote:
> > On Wed, Apr 27, 2011 at 7:33 AM, Minchan Kim <minchan.kim@gmail.com> wrote:
> >> On Tue, Apr 26, 2011 at 6:39 PM, Dave Young <hidave.darkstar@gmail.com> wrote:
> >>> On Tue, Apr 26, 2011 at 5:28 PM, Minchan Kim <minchan.kim@gmail.com> wrote:
> >>>> Please resend this with [2/2] to linux-mm.
> >>>>
> >>>> On Tue, Apr 26, 2011 at 5:59 PM, Dave Young <hidave.darkstar@gmail.com> wrote:
> >>>>> When memory pressure is high, virtio ballooning will probably cause oom killing.
> >>>>> Even if alloc_page with GFP_NORETRY itself does not directly trigger oom it
> >>>>> will make memory becoming low then memory alloc of other processes will trigger
> >>>>> oom killing. It is not desired behaviour.
> >>>>
> >>>> I can't understand why it is undesirable.
> >>>> Why do we have to handle it specially?
> >>>>
> >>>
> >>> Suppose user run some random memory hogging process while ballooning
> >>> it will be undesirable.
> >>
> >>
> >> In VM POV, kvm and random memory hogging processes are customers.
> >> If we handle ballooning specially with disable OOM, what happens other
> >> processes requires memory at same time? Should they wait for balloon
> >> driver to release memory?
> >>
> >> I don't know your point. Sorry.
> >> Could you explain your scenario in detail for justify your idea?
> >
> > What you said make sense I understand what you said now. Lets ignore
> > my above argue and see what I'm actually doing.
> >
> > I'm hacking with balloon driver to fit to short the vm migration time.
> >
> > while migrating host tell guest to balloon as much memory as it can, then start
> > migrate, just skip the ballooned pages, after migration done tell
> > guest to release the memory.
> >
> > In migration case oom is not I want to see and disable oom will be good.
> 
> BTW, if oom_killer_disabled is really not recommended to use I can
> switch back to oom_notifier way.

Could you please explain why you dislike oom_notifier and what problem
you faced? I haven't understand why oom_notifier is bad. probably my
less knowledge of balloon is a reason.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
