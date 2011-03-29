Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 99A138D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 15:54:52 -0400 (EDT)
Received: by qyk30 with SMTP id 30so542991qyk.14
        for <linux-mm@kvack.org>; Tue, 29 Mar 2011 12:54:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <AANLkTi=gMP6jQuQFovfsOX=7p-SSnwXoVLO_DVEpV63h@mail.gmail.com>
References: <9bde694e1003020554p7c8ff3c2o4ae7cb5d501d1ab9@mail.gmail.com>
	<AANLkTinnqtXf5DE+qxkTyZ9p9Mb8dXai6UxWP2HaHY3D@mail.gmail.com>
	<1300960540.32158.13.camel@e102109-lin.cambridge.arm.com>
	<AANLkTim139fpJsMJFLiyUYvFgGMz-Ljgd_yDrks-tqhE@mail.gmail.com>
	<1301395206.583.53.camel@e102109-lin.cambridge.arm.com>
	<AANLkTim-4v5Cbp6+wHoXjgKXoS0axk1cgQ5AHF_zot80@mail.gmail.com>
	<1301399454.583.66.camel@e102109-lin.cambridge.arm.com>
	<AANLkTin0_gT0E3=oGyfMwk+1quqonYBExeN9a3=v=Lob@mail.gmail.com>
	<AANLkTi=gMP6jQuQFovfsOX=7p-SSnwXoVLO_DVEpV63h@mail.gmail.com>
Date: Tue, 29 Mar 2011 22:54:50 +0300
Message-ID: <AANLkTimu54k-EEqfN58-hNTTgc54HktEeao+TyaKD30Z@mail.gmail.com>
Subject: Re: kmemleak for MIPS
From: Daniel Baluta <daniel.baluta@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Maxin John <maxin.john@gmail.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, naveen yadav <yad.naveen@gmail.com>, linux-mips@linux-mips.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Mar 29, 2011 at 10:36 PM, Maxin John <maxin.john@gmail.com> wrote:
> Hi,
>
> I have prepared the combined patch for kmemleak porting to MIPS. After
> applying the patch and enabling the kmemleak in Kernel, I can see one
> kernel memleak reported during booting itself:
> ..
> ..
>
> TCP cubic registered
> NET: Registered protocol family 17
> NET: Registered protocol family 15
> kmemleak: Kernel memory leak detector initialized
> rtc_cmos rtc_cmos: setting system clock to 2011-03-29 18:20:41 UTC (13014=
22841)
> kmemleak: Automatic memory scanning thread started
> EXT3-fs: barriers not enabled
> kjournald starting. =A0Commit interval 5 seconds
> EXT3-fs (hda1): mounted filesystem with ordered data mode
> VFS: Mounted root (ext3 filesystem) readonly on device 3:1.
> Freeing prom memory: 956k freed
> Freeing unused kernel memory: 244k freed
> modprobe: FATAL: Could not load
> /lib/modules/2.6.38-08826-g1788c20-dirty/modules.dep: No such file or
> directory
>
> INIT: version 2.86 booting
> Starting the hotplug events dispatcher: udevdudevd (863):
> /proc/863/oom_adj is deprecated, please use /proc/863/oom_score_adj
> instead.
> .
> Synthesizing the initial hotplug events...done.
> Waiting for /dev to be fully populated...kmemleak: 1 new suspected
> memory leaks (see /sys/kernel/debug/kmemleak)
> ....
> ....
>
> debian-mips:~#
> debian-mips:~# mount -t debugfs nodev /sys/kernel/debug/
> debian-mips:~# =A0cat /sys/kernel/debug/kmemleak
> unreferenced object 0x8f90d000 (size 4096):
> =A0comm "swapper", pid 1, jiffies 4294937330 (age 815.000s)
> =A0hex dump (first 32 bytes):
> =A0 =A000 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 =A0...............=
.
> =A0 =A000 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 =A0...............=
.
> =A0backtrace:
> =A0 =A0[<80529644>] alloc_large_system_hash+0x2f8/0x410
> =A0 =A0[<805383b4>] udp_table_init+0x4c/0x158
> =A0 =A0[<805384dc>] udp_init+0x1c/0x94
> =A0 =A0[<8053889c>] inet_init+0x184/0x2a0
> =A0 =A0[<80100584>] do_one_initcall+0x174/0x1e0
> =A0 =A0[<8051f348>] kernel_init+0xe4/0x174
> =A0 =A0[<80103d4c>] kernel_thread_helper+0x10/0x18
>
>
> The standard kmemleak test case is behaving as expected. Based on
> this, I think, we can say that the kmemleak support for MIPS is
> working.
>
> Please let me know your comments.

This looks good to me.

thanks,
Daniel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
