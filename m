Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id B89EE60080F
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 21:20:15 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o7O1KCCh006031
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 24 Aug 2010 10:20:12 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4DFC245DE59
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 10:20:12 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 252D745DE54
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 10:20:12 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id E59651DB803F
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 10:20:11 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 62D911DB805A
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 10:20:11 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 4/4] writeback: Reporting dirty thresholds in /proc/vmstat
In-Reply-To: <AANLkTikS+DUfPz0E2SmCZTQBWL8h2zSsGM8--yqEaVgZ@mail.gmail.com>
References: <20100821054808.GA29869@localhost> <AANLkTikS+DUfPz0E2SmCZTQBWL8h2zSsGM8--yqEaVgZ@mail.gmail.com>
Message-Id: <20100824100943.F3B6.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Date: Tue, 24 Aug 2010 10:20:10 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Michael Rubin <mrubin@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Wu Fengguang <fengguang.wu@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "jack@suse.cz" <jack@suse.cz>, "riel@redhat.com" <riel@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "david@fromorbit.com" <david@fromorbit.com>, "npiggin@kernel.dk" <npiggin@kernel.dk>, "hch@lst.de" <hch@lst.de>, "axboe@kernel.dk" <axboe@kernel.dk>
List-ID: <linux-mm.kvack.org>

> On Fri, Aug 20, 2010 at 10:48 PM, Wu Fengguang <fengguang.wu@intel.com> w=
rote:
> > On Fri, Aug 20, 2010 at 05:31:29PM +0800, Michael Rubin wrote:
> >> The kernel already exposes the user desired thresholds in /proc/sys/vm
> >> with dirty_background_ratio and background_ratio. But the kernel may
> >> alter the number requested without giving the user any indication that
> >> is the case.
> >>
> >> Knowing the actual ratios the kernel is honoring can help app develope=
rs
> >> understand how their buffered IO will be sent to the disk.
> >>
> >> =A0 =A0 =A0 $ grep threshold /proc/vmstat
> >> =A0 =A0 =A0 nr_dirty_threshold 409111
> >> =A0 =A0 =A0 nr_dirty_background_threshold 818223
> >
> > I realized that the dirty thresholds has already been exported here:
> >
> > $ grep Thresh =A0/debug/bdi/8:0/stats
> > BdiDirtyThresh: =A0 =A0 381000 kB
> > DirtyThresh: =A0 =A0 =A0 1719076 kB
> > BackgroundThresh: =A0 859536 kB
> >
> > So why not use that interface directly?
>=20
> LOL. I know about these counters. This goes back and forth a lot.
> The reason we don't want to use this interface is several fold.

Please don't use LOL if you want to get good discuttion. afaict, Wu have
deep knowledge in this area. However all kernel-developer don't know all
kernel knob.

>=20
> 1) It's exporting the implementation of writeback. We are doing bdi
> today but one day we may not.
> 2) We need a non debugfs version since there are many situations where
> debugfs requires root to mount and non root users may want this data.
> Mounting debugfs all the time is not always an option.

In nowadays, many distro mount debugfs at boot time. so, can you please
elaborate you worried risk?  even though we have namespace.


> 3) Full system counters are easier to handle the juggling of removable
> storage where these numbers will appear and disappear due to being
> dynamic.
>=20
> The goal is to get a full view of the system writeback behaviour not a
> "kinda got it-oops maybe not" view.

I bet nobody oppose this point :)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
