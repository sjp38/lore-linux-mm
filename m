Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id DEC936B0005
	for <linux-mm@kvack.org>; Sat, 19 Mar 2016 08:14:01 -0400 (EDT)
Received: by mail-wm0-f46.google.com with SMTP id l68so69753514wml.1
        for <linux-mm@kvack.org>; Sat, 19 Mar 2016 05:14:01 -0700 (PDT)
Received: from mail-wm0-x236.google.com (mail-wm0-x236.google.com. [2a00:1450:400c:c09::236])
        by mx.google.com with ESMTPS id iw2si21291650wjb.101.2016.03.19.05.14.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 19 Mar 2016 05:14:00 -0700 (PDT)
Received: by mail-wm0-x236.google.com with SMTP id l68so69753236wml.1
        for <linux-mm@kvack.org>; Sat, 19 Mar 2016 05:14:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <7300.1458333684@turing-police.cc.vt.edu>
References: <7300.1458333684@turing-police.cc.vt.edu>
Date: Sat, 19 Mar 2016 13:13:59 +0100
Message-ID: <CAG_fn=WKjdcUSi5JoiAPrmRCLEL-SWyGHCOYOZiZQ_fnFDvydQ@mail.gmail.com>
Subject: Re: KASAN overhead?
From: Alexander Potapenko <glider@google.com>
Content-Type: multipart/alternative; boundary=001a1144046e6ff7f4052e65cc53
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
Cc: Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>

--001a1144046e6ff7f4052e65cc53
Content-Type: text/plain; charset=UTF-8

On Mar 18, 2016 9:41 PM, "Valdis Kletnieks" <Valdis.Kletnieks@vt.edu> wrote:
>
> So I built linux-next next-20160417 with KASAN enabled:
Is that next-20160317?

> CONFIG_KASAN_SHADOW_OFFSET=0xdffffc0000000000
> CONFIG_HAVE_ARCH_KASAN=y
> CONFIG_KASAN=y
> # CONFIG_KASAN_OUTLINE is not set
> CONFIG_KASAN_INLINE=y
> CONFIG_TEST_KASAN=m
Which GCC version were you using? Are you sure it didn't accidentally
enable the outline instrumentation (e.g. if the compiler is too old)?

> and saw an *amazing* slowdown.
Have you tried earlier KASAN versions? Is this a recent regression?

> For comparison, here is the time taken
> to reach various points in the dmesg:
>
> % grep -i free dmesg.0317*
> dmesg.0317:[    1.560907] Freeing SMP alternatives memory: 28K
(ffffffff93d3e000 - ffffffff93d45000)
> dmesg.0317:[   12.041550] Freeing initrd memory: 10432K (ffff88003f5cb000
- ffff88003fffb000)
> dmesg.0317:[   16.458451] ata1.00: ACPI cmd f5/00:00:00:00:00:00
(SECURITY FREEZE LOCK) filtered out
> dmesg.0317:[   16.545603] ata1.00: ACPI cmd f5/00:00:00:00:00:00
(SECURITY FREEZE LOCK) filtered out
> dmesg.0317:[   17.818934] Freeing unused kernel memory: 1628K
(ffffffff93ba7000 - ffffffff93d3e000)
> dmesg.0317:[   17.820234] Freeing unused kernel memory: 1584K
(ffff880012c74000 - ffff880012e00000)
> dmesg.0317:[   17.828426] Freeing unused kernel memory: 1524K
(ffff880013483000 - ffff880013600000)
> dmesg.0317-nokasan:[    0.028821] Freeing SMP alternatives memory: 28K
(ffffffffaf104000 - ffffffffaf10b000)
> dmesg.0317-nokasan:[    1.587232] Freeing initrd memory: 10432K
(ffff88003f5cb000 - ffff88003fffb000)
> dmesg.0317-nokasan:[    2.433557] ata1.00: ACPI cmd f5/00:00:00:00:00:00
(SECURITY FREEZE LOCK) filtered out
> dmesg.0317-nokasan:[    2.439411] ata1.00: ACPI cmd f5/00:00:00:00:00:00
(SECURITY FREEZE LOCK) filtered out
> dmesg.0317-nokasan:[    2.488113] Freeing unused kernel memory: 1324K
(ffffffffaefb9000 - ffffffffaf104000)
> dmesg.0317-nokasan:[    2.488518] Freeing unused kernel memory: 88K
(ffff88002e9ea000 - ffff88002ea00000)
> dmesg.0317-nokasan:[    2.489490] Freeing unused kernel memory: 388K
(ffff88002ed9f000 - ffff88002ee00000)

Was KASAN reporting anything between these lines? Sometimes a recurring
warning slows everything down.

> Only config difference was changing to CONFIG_KASAN=n.
>
> Is this level of slowdown expected? Or is my kernel unexpectedly off in
the weeds?
How did it behave after the startup? Was it still slow?
Which machine were you using? Was it a real device or a VM?

--001a1144046e6ff7f4052e65cc53
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<p dir=3D"ltr">On Mar 18, 2016 9:41 PM, &quot;Valdis Kletnieks&quot; &lt;<a=
 href=3D"mailto:Valdis.Kletnieks@vt.edu">Valdis.Kletnieks@vt.edu</a>&gt; wr=
ote:<br>
&gt;<br>
&gt; So I built linux-next next-20160417 with KASAN enabled:<br>
Is that next-20160317?</p>
<p dir=3D"ltr">&gt; CONFIG_KASAN_SHADOW_OFFSET=3D0xdffffc0000000000<br>
&gt; CONFIG_HAVE_ARCH_KASAN=3Dy<br>
&gt; CONFIG_KASAN=3Dy<br>
&gt; # CONFIG_KASAN_OUTLINE is not set<br>
&gt; CONFIG_KASAN_INLINE=3Dy<br>
&gt; CONFIG_TEST_KASAN=3Dm<br>
Which GCC version were you using? Are you sure it didn&#39;t accidentally e=
nable the outline instrumentation (e.g. if the compiler is too old)?</p>
<p dir=3D"ltr">&gt; and saw an *amazing* slowdown.=C2=A0 <br>
Have you tried earlier KASAN versions? Is this a recent regression?</p>
<p dir=3D"ltr">&gt; For comparison, here is the time taken<br>
&gt; to reach various points in the dmesg:<br>
&gt;<br>
&gt; % grep -i free dmesg.0317*<br>
&gt; dmesg.0317:[=C2=A0 =C2=A0 1.560907] Freeing SMP alternatives memory: 2=
8K (ffffffff93d3e000 - ffffffff93d45000)<br>
&gt; dmesg.0317:[=C2=A0 =C2=A012.041550] Freeing initrd memory: 10432K (fff=
f88003f5cb000 - ffff88003fffb000)<br>
&gt; dmesg.0317:[=C2=A0 =C2=A016.458451] ata1.00: ACPI cmd f5/00:00:00:00:0=
0:00 (SECURITY FREEZE LOCK) filtered out<br>
&gt; dmesg.0317:[=C2=A0 =C2=A016.545603] ata1.00: ACPI cmd f5/00:00:00:00:0=
0:00 (SECURITY FREEZE LOCK) filtered out<br>
&gt; dmesg.0317:[=C2=A0 =C2=A017.818934] Freeing unused kernel memory: 1628=
K (ffffffff93ba7000 - ffffffff93d3e000)<br>
&gt; dmesg.0317:[=C2=A0 =C2=A017.820234] Freeing unused kernel memory: 1584=
K (ffff880012c74000 - ffff880012e00000)<br>
&gt; dmesg.0317:[=C2=A0 =C2=A017.828426] Freeing unused kernel memory: 1524=
K (ffff880013483000 - ffff880013600000)<br>
&gt; dmesg.0317-nokasan:[=C2=A0 =C2=A0 0.028821] Freeing SMP alternatives m=
emory: 28K (ffffffffaf104000 - ffffffffaf10b000)<br>
&gt; dmesg.0317-nokasan:[=C2=A0 =C2=A0 1.587232] Freeing initrd memory: 104=
32K (ffff88003f5cb000 - ffff88003fffb000)<br>
&gt; dmesg.0317-nokasan:[=C2=A0 =C2=A0 2.433557] ata1.00: ACPI cmd f5/00:00=
:00:00:00:00 (SECURITY FREEZE LOCK) filtered out<br>
&gt; dmesg.0317-nokasan:[=C2=A0 =C2=A0 2.439411] ata1.00: ACPI cmd f5/00:00=
:00:00:00:00 (SECURITY FREEZE LOCK) filtered out<br>
&gt; dmesg.0317-nokasan:[=C2=A0 =C2=A0 2.488113] Freeing unused kernel memo=
ry: 1324K (ffffffffaefb9000 - ffffffffaf104000)<br>
&gt; dmesg.0317-nokasan:[=C2=A0 =C2=A0 2.488518] Freeing unused kernel memo=
ry: 88K (ffff88002e9ea000 - ffff88002ea00000)<br>
&gt; dmesg.0317-nokasan:[=C2=A0 =C2=A0 2.489490] Freeing unused kernel memo=
ry: 388K (ffff88002ed9f000 - ffff88002ee00000)</p>
<p dir=3D"ltr">Was KASAN reporting anything between these lines? Sometimes =
a recurring warning slows everything down.</p>
<p dir=3D"ltr">&gt; Only config difference was changing to CONFIG_KASAN=3Dn=
.<br>
&gt;<br>
&gt; Is this level of slowdown expected? Or is my kernel unexpectedly off i=
n the weeds?<br>
How did it behave after the startup? Was it still slow?<br>
Which machine were you using? Was it a real device or a VM?</p>

--001a1144046e6ff7f4052e65cc53--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
