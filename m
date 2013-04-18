Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 1AFF76B0005
	for <linux-mm@kvack.org>; Thu, 18 Apr 2013 02:27:49 -0400 (EDT)
Date: Thu, 18 Apr 2013 02:27:45 -0400 (EDT)
From: Zhouping Liu <zliu@redhat.com>
Message-ID: <1638103518.2400447.1366266465689.JavaMail.root@redhat.com>
In-Reply-To: <20130416075047.GA4184@osiris>
References: <156480624.266924.1365995933797.JavaMail.root@redhat.com> <2068164110.268217.1365996520440.JavaMail.root@redhat.com> <20130415055627.GB4207@osiris> <516B9B57.6050308@redhat.com> <20130416075047.GA4184@osiris>
Subject: Re: [BUG][s390x] mm: system crashed
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, caiqian <caiqian@redhat.com>, Caspar Zhang <czhang@redhat.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

Hello Heiko,

----- Original Message -----
> From: "Heiko Carstens" <heiko.carstens@de.ibm.com>
> To: "Zhouping Liu" <zliu@redhat.com>
> Cc: linux-mm@kvack.org, "LKML" <linux-kernel@vger.kernel.org>, "caiqian" =
<caiqian@redhat.com>, "Caspar Zhang"
> <czhang@redhat.com>, "Martin Schwidefsky" <schwidefsky@de.ibm.com>
> Sent: Tuesday, April 16, 2013 3:50:47 PM
> Subject: Re: [BUG][s390x] mm: system crashed
>=20
> On Mon, Apr 15, 2013 at 02:16:55PM +0800, Zhouping Liu wrote:
> > On 04/15/2013 01:56 PM, Heiko Carstens wrote:
> > >On Sun, Apr 14, 2013 at 11:28:40PM -0400, Zhouping Liu wrote:
> > >>=EF=BF=BD 16109.346170=C2=A8 Call Trace:
> > >>=EF=BF=BD 16109.346179=C2=A8 (=EF=BF=BD <0000000000100920>=C2=A8 show=
_trace+0x128/0x12c)
> > >>=EF=BF=BD 16109.346195=C2=A8  =EF=BF=BD <00000000001cd320>=C2=A8 rcu_=
check_callbacks+0x458/0xccc
> > >>=EF=BF=BD 16109.346209=C2=A8  =EF=BF=BD <0000000000140f2e>=C2=A8 upda=
te_process_times+0x4a/0x74
> > >>=EF=BF=BD 16109.346222=C2=A8  =EF=BF=BD <0000000000199452>=C2=A8
> > >>tick_sched_handle.isra.12+0x5e/0x70
> > >>=EF=BF=BD 16109.346235=C2=A8  =EF=BF=BD <00000000001995aa>=C2=A8 tick=
_sched_timer+0x6a/0x98
> > >>=EF=BF=BD 16109.346247=C2=A8  =EF=BF=BD <000000000015c1ea>=C2=A8 __ru=
n_hrtimer+0x8e/0x200
> > >>=EF=BF=BD 16109.346381=C2=A8  =EF=BF=BD <000000000015d1b2>=C2=A8 hrti=
mer_interrupt+0x212/0x2b0
> > >>=EF=BF=BD 16109.346385=C2=A8  =EF=BF=BD <00000000001040f6>=C2=A8 cloc=
k_comparator_work+0x4a/0x54
> > >>=EF=BF=BD 16109.346390=C2=A8  =EF=BF=BD <000000000010d658>=C2=A8 do_e=
xtint+0x158/0x15c
> > >>=EF=BF=BD 16109.346396=C2=A8  =EF=BF=BD <000000000062aa24>=C2=A8 ext_=
skip+0x38/0x3c
> > >>=EF=BF=BD 16109.346404=C2=A8  =EF=BF=BD <00000000001153c8>=C2=A8 smp_=
yield_cpu+0x44/0x48
> > >>=EF=BF=BD 16109.346412=C2=A8 (=EF=BF=BD <000003d10051aec0>=C2=A8 0x3d=
10051aec0)
> > >>=EF=BF=BD 16109.346457=C2=A8  =EF=BF=BD <000000000024206a>=C2=A8 __pa=
ge_check_address+0x16a/0x170
> > >>=EF=BF=BD 16109.346466=C2=A8  =EF=BF=BD <00000000002423a2>=C2=A8 page=
_referenced_one+0x3e/0xa0
> > >>=EF=BF=BD 16109.346501=C2=A8  =EF=BF=BD <000000000024427c>=C2=A8 page=
_referenced+0x32c/0x41c
> > >>=EF=BF=BD 16109.346510=C2=A8  =EF=BF=BD <000000000021b1dc>=C2=A8 shri=
nk_page_list+0x380/0xb9c
> > >>=EF=BF=BD 16109.346521=C2=A8  =EF=BF=BD <000000000021c0a6>=C2=A8 shri=
nk_inactive_list+0x1c6/0x56c
> > >>=EF=BF=BD 16109.346532=C2=A8  =EF=BF=BD <000000000021c69e>=C2=A8 shri=
nk_lruvec+0x252/0x56c
> > >>=EF=BF=BD 16109.346542=C2=A8  =EF=BF=BD <000000000021ca44>=C2=A8 shri=
nk_zone+0x8c/0x1bc
> > >>=EF=BF=BD 16109.346553=C2=A8  =EF=BF=BD <000000000021d080>=C2=A8 bala=
nce_pgdat+0x50c/0x658
> > >>=EF=BF=BD 16109.346564=C2=A8  =EF=BF=BD <000000000021d318>=C2=A8 kswa=
pd+0x14c/0x470
> > >>=EF=BF=BD 16109.346576=C2=A8  =EF=BF=BD <0000000000158292>=C2=A8 kthr=
ead+0xda/0xe4
> > >>=EF=BF=BD 16109.346656=C2=A8  =EF=BF=BD <000000000062a5de>=C2=A8 kern=
el_thread_starter+0x6/0xc
> > >>=EF=BF=BD 16109.346682=C2=A8  =EF=BF=BD <000000000062a5d8>=C2=A8 kern=
el_thread_starter+0x0/0xc
> > >>[-- MARK -- Fri Apr 12 06:15:00 2013]
> > >>=EF=BF=BD 16289.386061=C2=A8 INFO: rcu_sched self-detected stall on C=
PU { 0}  (t=3D42010
> > >>jiffies
> > >>  g=3D89766 c=3D89765 q=3D10627)
> > >Did the system really crash or did you just see the rcu related
> > >warning(s)?
> >=20
> > I just check it again, actually at first the system didn't really
> > crash, but the system is very slow in response.
> > and the reproducer process can't be killed, after I did some common
> > actions such as 'ls' 'vim' etc, the system
> > seemed to be really crashed, no any response.
> >=20
> > also in the previous testing, I can remember that the system would
> > be no any response for a long time, just only
> > repeatedly print out the such above 'Call Trace' into console.
>=20
> Ok, thanks.
> Just a couple of more questions: did you see this also on other archs, or
> just
> s390 (if you tried other platforms at all).
>=20
> If you have some time, could you please repeat your test with the kernel
> command line option " user_mode=3Dhome "?

I tested the system with the kernel parameter, but the issue still appeared=
,
I just to say it takes longer time to reproduce the issue than the before.

>=20
> As far as I can tell there was only one s390 patch merged that was
> mmap related: 486c0a0bc80d370471b21662bf03f04fbb37cdc6 "s390/mm: Fix crst
> upgrade of mmap with MAP_FIXED".

also I tested the revert commit, unluckily, the same issue as the before.


--=20
Thanks,
Zhouping

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
