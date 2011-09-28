Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 79D379000BD
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 10:10:01 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <22173398-de03-43ef-abe4-a3f3231dd2e9@default>
Date: Wed, 28 Sep 2011 07:09:18 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH V10 0/6] mm: frontswap: overview (and proposal to merge at
 next window)
References: <20110915213305.GA26317@ca-server1.us.oracle.com
 20110928151558.dca1da5e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110928151558.dca1da5e.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hughd@google.com, ngupta@vflare.org, Konrad Wilk <konrad.wilk@oracle.com>, JBeulich@novell.com, Kurt Hackel <kurt.hackel@oracle.com>, npiggin@kernel.dk, akpm@linux-foundation.org, riel@redhat.com, hannes@cmpxchg.org, matthew@wil.cx, Chris Mason <chris.mason@oracle.com>, sjenning@linux.vnet.ibm.com, jackdachef@gmail.com, cyclonusj@gmail.com, levinsasha928@gmail.com

> From: KAMEZAWA Hiroyuki [mailto:kamezawa.hiroyu@jp.fujitsu.com]
> Sent: Wednesday, September 28, 2011 12:16 AM
> To: Dan Magenheimer
> Cc: linux-kernel@vger.kernel.org; linux-mm@kvack.org; jeremy@goop.org; hu=
ghd@google.com;
> ngupta@vflare.org; Konrad Wilk; JBeulich@novell.com; Kurt Hackel; npiggin=
@kernel.dk; akpm@linux-
> foundation.org; riel@redhat.com; hannes@cmpxchg.org; matthew@wil.cx; Chri=
s Mason;
> sjenning@linux.vnet.ibm.com; jackdachef@gmail.com; cyclonusj@gmail.com; l=
evinsasha928@gmail.com
> Subject: Re: [PATCH V10 0/6] mm: frontswap: overview (and proposal to mer=
ge at next window)
>=20
> On Thu, 15 Sep 2011 14:33:05 -0700
> Dan Magenheimer <dan.magenheimer@oracle.com> wrote:
>=20
> > [PATCH V10 0/6] mm: frontswap: overview (and proposal to merge at next =
window)
> >
> > (Note: V9->V10 only change is corrections in debugfs-related code/count=
ers)
> >
> > (Note to earlier reviewers:  This patchset was reorganized at V9 due
> > to feedback from Kame Hiroyuki and Andrew Morton.  Additionally, feedba=
ck
> > on frontswap v8 from Andrew Morton also applies to cleancache, to wit:
> >  (1) change usage of sysfs to debugfs to avoid unnecessary kernel ABIs
> >  (2) rename all uses of "flush" to "invalidate"
> > As a result, additional patches (5of6 and 6of6) were added to this
> > series at V9 to patch cleancache core code and cleancache hooks in the =
mm
> > and fs subsystems and update cleancache documentation accordingly.)
>=20
> I'm sorry I couldn't catch following... what happens at hibernation ?
> frontswap is effectively stopped/skipped automatically ? or contents of
> TMEM can be kept after power off and it can be read correctly when
> resume thread reads swap ?
>=20
> In short: no influence to hibernation ?
> I'm sorry if I misunderstand some.

Hi Kame --

Hibernation would need to be handled by the tmem backend (e.g. zcache, Xen
tmem).  In the case of Xen tmem, both save/restore and live migration are
fully supported.  I'm not sure if zcache works across hibernation; since
all memory is kmalloc'ed, I think it should work fine, but it would be an
interesting experiment.

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
