Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 500456B00A2
	for <linux-mm@kvack.org>; Wed, 29 Dec 2010 16:50:42 -0500 (EST)
Received: from kpbe13.cbf.corp.google.com (kpbe13.cbf.corp.google.com [172.25.105.77])
	by smtp-out.google.com with ESMTP id oBTLoaeW003632
	for <linux-mm@kvack.org>; Wed, 29 Dec 2010 13:50:37 -0800
Received: from gxk25 (gxk25.prod.google.com [10.202.11.25])
	by kpbe13.cbf.corp.google.com with ESMTP id oBTLoYxR018126
	for <linux-mm@kvack.org>; Wed, 29 Dec 2010 13:50:35 -0800
Received: by gxk25 with SMTP id 25so2071835gxk.9
        for <linux-mm@kvack.org>; Wed, 29 Dec 2010 13:50:34 -0800 (PST)
Date: Wed, 29 Dec 2010 13:50:22 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: 2.6.37-rc7: NULL pointer dereference
In-Reply-To: <20101222164151.GA2048@cmpxchg.org>
Message-ID: <alpine.LSU.2.00.1012291344460.22803@sister.anvils>
References: <1293020757.1998.2.camel@localhost.localdomain> <AANLkTin6GMiXHuoVzNWPcj0jXDqWyfWCwW9fd-v=pq=X@mail.gmail.com> <20101222164151.GA2048@cmpxchg.org>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323584-672622310-1293659434=:22803"
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, Thomas Meyer <thomas@m3y3r.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>
List-ID: <linux-mm.kvack.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323584-672622310-1293659434=:22803
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Wed, 22 Dec 2010, Johannes Weiner wrote:
> On Thu, Dec 23, 2010 at 12:37:11AM +0900, Minchan Kim wrote:
> > On Wed, Dec 22, 2010 at 9:25 PM, Thomas Meyer <thomas@m3y3r.de> wrote:
> > > BUG: unable to handle kernel NULL pointer dereference at 00000008
> > > IP: [<c04eae14>] __mem_cgroup_try_charge+0x234/0x430
> > > Process swapoff (pid: 8058, ti=3Df2e70000 task=3Df3e55860 task.ti=3Df=
2e70000)
> > > Call Trace:
> > > =A0[<c0456607>] ? ktime_get_ts+0x107/0x140
> > > =A0[<c04ebb89>] ? mem_cgroup_try_charge_swapin+0x49/0xb0
> > > =A0[<c04d9b4b>] ? unuse_mm+0x1db/0x300
> > > =A0[<c04dad9a>] ? sys_swapoff+0x2aa/0x890
> > > =A0[<c047cd58>] ? audit_syscall_entry+0x218/0x240
> > > =A0[<c047d043>] ? audit_syscall_exit+0x1f3/0x220
> > > =A0[<c0403013>] ? sysenter_do_call+0x12/0x22
>=20
> This could be explained by a kernel without VM_BUG_ON(), where
> !mm->owner goes uncaught until css_tryget() reads mem.css.flags (eight
> bytes member offset on 32-bit).
>=20
> Does
> =09http://marc.info/?l=3Dlinux-mm&m=3D128889198016021&w=3D2
> help?

I'm sure you're right, Hannes.  Thanks for the prod.  Sadly, Kame
and I both let the fix drift, expecting it to magick its way into
Linus's tree.  We're now at rc8: I'd better change my Acked-by to
a Signed-off-by and try sending it in immediately: will do so now.

Hugh
--8323584-672622310-1293659434=:22803--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
