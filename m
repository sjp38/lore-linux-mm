Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1BF448D0017
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 03:46:55 -0500 (EST)
Subject: Re: fadvise DONTNEED implementation (or lack thereof)
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <AANLkTim59Qx6TsvXnTBL5Lg6JorbGaqx3KsdBDWO04X9@mail.gmail.com>
References: <20101109162525.BC87.A69D9226@jp.fujitsu.com>
	 <877hgmr72o.fsf@gmail.com> <20101114140920.E013.A69D9226@jp.fujitsu.com>
	 <AANLkTim59Qx6TsvXnTBL5Lg6JorbGaqx3KsdBDWO04X9@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Mon, 15 Nov 2010 09:47:05 +0100
Message-ID: <1289810825.2109.469.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Ben Gamari <bgamari.foss@gmail.com>, linux-kernel@vger.kernel.org, rsync@lists.samba.org, linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2010-11-15 at 15:07 +0900, Minchan Kim wrote:
> On Sun, Nov 14, 2010 at 2:09 PM, KOSAKI Motohiro
> <kosaki.motohiro@jp.fujitsu.com> wrote:
> >> On Tue,  9 Nov 2010 16:28:02 +0900 (JST), KOSAKI Motohiro <kosaki.moto=
hiro@jp.fujitsu.com> wrote:
> >> > So, I don't think application developers will use fadvise() aggressi=
vely
> >> > because we don't have a cross platform agreement of a fadvice behavi=
or.
> >> >
> >> I strongly disagree. For a long time I have been trying to resolve
> >> interactivity issues caused by my rsync-based backup script. Many kern=
el
> >> developers have said that there is nothing the kernel can do without
> >> more information from user-space (e.g. cgroups, madvise). While cgroup=
s
> >> help, the fix is round-about at best and requires configuration where
> >> really none should be necessary. The easiest solution for everyone
> >> involved would be for rsync to use FADV_DONTNEED. The behavior doesn't
> >> need to be perfectly consistent between platforms for the flag to be
> >> useful so long as each implementation does something sane to help
> >> use-once access patterns.
> >>
> >> People seem to mention frequently that there are no users of
> >> FADV_DONTNEED and therefore we don't need to implement it. It seems li=
ke
> >> this is ignoring an obvious catch-22. Currently rsync has no fadvise
> >> support at all, since using[1] the implemented hints to get the desire=
d
> >> effect is far too complicated^M^M^M^Mhacky to be considered
> >> merge-worthy. Considering the number of Google hits returned for
> >> fadvise, I wouldn't be surprised if there were countless other project=
s
> >> with this same difficulty. We want to be able to tell the kernel about
> >> our useage patterns, but the kernel won't listen.
> >
> > Because we have an alternative solution already. please try memcgroup :=
)

Using memcgroup for this is utter crap, it just contains the trainwreck,
it doesn't solve it in any way.

> I think memcg could be a solution of them but fundamental solution is
> that we have to cure it in VM itself.
> I feel it's absolutely absurd to enable and use memcg for amending it.

Agreed..

> I wonder what's the problem in Peter's patch 'drop behind'.
> http://www.mail-archive.com/linux-kernel@vger.kernel.org/msg179576.html
>=20
> Could anyone tell me why it can't accept upstream?

Read the thread, its quite clear nobody got convinced it was a good idea
and wanted to fix the use-once policy, then Rik rewrote all of
page-reclaim.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
