Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id C41E86B0002
	for <linux-mm@kvack.org>; Sun, 14 Apr 2013 23:28:41 -0400 (EDT)
Date: Sun, 14 Apr 2013 23:28:40 -0400 (EDT)
From: Zhouping Liu <zliu@redhat.com>
Message-ID: <2068164110.268217.1365996520440.JavaMail.root@redhat.com>
In-Reply-To: <156480624.266924.1365995933797.JavaMail.root@redhat.com>
Subject: [BUG][s390x] mm: system crashed
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
Cc: caiqian <caiqian@redhat.com>, Caspar Zhang <czhang@redhat.com>

Hi All,

I hit the below crashed when doing memory related tests[1] on s390x:

--------------- snip ---------------------
=EF=BF=BD 15929.351639=C2=A8  =EF=BF=BD <000000000021c0a6>=C2=A8 shrink_ina=
ctive_list+0x1c6/0x56c=20
=EF=BF=BD 15929.351647=C2=A8  =EF=BF=BD <000000000021c69e>=C2=A8 shrink_lru=
vec+0x252/0x56c=20
=EF=BF=BD 15929.351654=C2=A8  =EF=BF=BD <000000000021ca44>=C2=A8 shrink_zon=
e+0x8c/0x1bc=20
=EF=BF=BD 15929.351662=C2=A8  =EF=BF=BD <000000000021d080>=C2=A8 balance_pg=
dat+0x50c/0x658=20
=EF=BF=BD 15929.351671=C2=A8  =EF=BF=BD <000000000021d318>=C2=A8 kswapd+0x1=
4c/0x470=20
=EF=BF=BD 15929.351680=C2=A8  =EF=BF=BD <0000000000158292>=C2=A8 kthread+0x=
da/0xe4=20
=EF=BF=BD 15929.351690=C2=A8  =EF=BF=BD <000000000062a5de>=C2=A8 kernel_thr=
ead_starter+0x6/0xc=20
=EF=BF=BD 15929.351700=C2=A8  =EF=BF=BD <000000000062a5d8>=C2=A8 kernel_thr=
ead_starter+0x0/0xc=20
=EF=BF=BD 16109.346061=C2=A8 INFO: rcu_sched self-detected stall on CPU { 0=
}  (t=3D24006 jiffies=20
 g=3D89766 c=3D89765 q=3D10544)=20
=EF=BF=BD 16109.346101=C2=A8 CPU: 0 Tainted: G      D      3.9.0-rc6+ #1=20
=EF=BF=BD 16109.346106=C2=A8 Process kswapd0 (pid: 28, task: 000000003b2a00=
00, ksp: 000000003b=20
2ab8c0)=20
=EF=BF=BD 16109.346110=C2=A8        000000000001bb60 000000000001bb70 00000=
00000000002 0000000=20
000000000=20
       000000000001bc00 000000000001bb78 000000000001bb78 00000000001009ca=
=20
       0000000000000000 0000000000002930 000000000000000a 000000000000000a=
=20
       000000000001bbc0 000000000001bb60 0000000000000000 0000000000000000=
=20
       000000000063bb18 00000000001009ca 000000000001bb60 000000000001bbb0=
=20
=EF=BF=BD 16109.346170=C2=A8 Call Trace:=20
=EF=BF=BD 16109.346179=C2=A8 (=EF=BF=BD <0000000000100920>=C2=A8 show_trace=
+0x128/0x12c)=20
=EF=BF=BD 16109.346195=C2=A8  =EF=BF=BD <00000000001cd320>=C2=A8 rcu_check_=
callbacks+0x458/0xccc=20
=EF=BF=BD 16109.346209=C2=A8  =EF=BF=BD <0000000000140f2e>=C2=A8 update_pro=
cess_times+0x4a/0x74=20
=EF=BF=BD 16109.346222=C2=A8  =EF=BF=BD <0000000000199452>=C2=A8 tick_sched=
_handle.isra.12+0x5e/0x70=20
=EF=BF=BD 16109.346235=C2=A8  =EF=BF=BD <00000000001995aa>=C2=A8 tick_sched=
_timer+0x6a/0x98=20
=EF=BF=BD 16109.346247=C2=A8  =EF=BF=BD <000000000015c1ea>=C2=A8 __run_hrti=
mer+0x8e/0x200=20
=EF=BF=BD 16109.346381=C2=A8  =EF=BF=BD <000000000015d1b2>=C2=A8 hrtimer_in=
terrupt+0x212/0x2b0=20
=EF=BF=BD 16109.346385=C2=A8  =EF=BF=BD <00000000001040f6>=C2=A8 clock_comp=
arator_work+0x4a/0x54=20
=EF=BF=BD 16109.346390=C2=A8  =EF=BF=BD <000000000010d658>=C2=A8 do_extint+=
0x158/0x15c=20
=EF=BF=BD 16109.346396=C2=A8  =EF=BF=BD <000000000062aa24>=C2=A8 ext_skip+0=
x38/0x3c=20
=EF=BF=BD 16109.346404=C2=A8  =EF=BF=BD <00000000001153c8>=C2=A8 smp_yield_=
cpu+0x44/0x48=20
=EF=BF=BD 16109.346412=C2=A8 (=EF=BF=BD <000003d10051aec0>=C2=A8 0x3d10051a=
ec0)=20
=EF=BF=BD 16109.346457=C2=A8  =EF=BF=BD <000000000024206a>=C2=A8 __page_che=
ck_address+0x16a/0x170=20
=EF=BF=BD 16109.346466=C2=A8  =EF=BF=BD <00000000002423a2>=C2=A8 page_refer=
enced_one+0x3e/0xa0=20
=EF=BF=BD 16109.346501=C2=A8  =EF=BF=BD <000000000024427c>=C2=A8 page_refer=
enced+0x32c/0x41c=20
=EF=BF=BD 16109.346510=C2=A8  =EF=BF=BD <000000000021b1dc>=C2=A8 shrink_pag=
e_list+0x380/0xb9c=20
=EF=BF=BD 16109.346521=C2=A8  =EF=BF=BD <000000000021c0a6>=C2=A8 shrink_ina=
ctive_list+0x1c6/0x56c=20
=EF=BF=BD 16109.346532=C2=A8  =EF=BF=BD <000000000021c69e>=C2=A8 shrink_lru=
vec+0x252/0x56c=20
=EF=BF=BD 16109.346542=C2=A8  =EF=BF=BD <000000000021ca44>=C2=A8 shrink_zon=
e+0x8c/0x1bc=20
=EF=BF=BD 16109.346553=C2=A8  =EF=BF=BD <000000000021d080>=C2=A8 balance_pg=
dat+0x50c/0x658=20
=EF=BF=BD 16109.346564=C2=A8  =EF=BF=BD <000000000021d318>=C2=A8 kswapd+0x1=
4c/0x470=20
=EF=BF=BD 16109.346576=C2=A8  =EF=BF=BD <0000000000158292>=C2=A8 kthread+0x=
da/0xe4=20
=EF=BF=BD 16109.346656=C2=A8  =EF=BF=BD <000000000062a5de>=C2=A8 kernel_thr=
ead_starter+0x6/0xc=20
=EF=BF=BD 16109.346682=C2=A8  =EF=BF=BD <000000000062a5d8>=C2=A8 kernel_thr=
ead_starter+0x0/0xc=20
[-- MARK -- Fri Apr 12 06:15:00 2013]=20
=EF=BF=BD 16289.386061=C2=A8 INFO: rcu_sched self-detected stall on CPU { 0=
}  (t=3D42010 jiffies=20
 g=3D89766 c=3D89765 q=3D10627)=20
-------------- snip ----------------------

The testing system has 1Gb RAM, kernel is new latest mainline.
please let me know if you need any more info.

[1] reproducer is come from LTP: https://github.com/linux-test-project/ltp/=
blob/master/testcases/kernel/mem/mtest06/mmap2.c
    and execute it using this command: `./mmap2 -x 0.002 -a -p`

--=20
Thanks,
Zhouping

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
