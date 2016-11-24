Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0F6196B0038
	for <linux-mm@kvack.org>; Thu, 24 Nov 2016 08:11:55 -0500 (EST)
Received: by mail-yw0-f200.google.com with SMTP id t11so40243454ywe.3
        for <linux-mm@kvack.org>; Thu, 24 Nov 2016 05:11:55 -0800 (PST)
Received: from mail-yw0-x22f.google.com (mail-yw0-x22f.google.com. [2607:f8b0:4002:c05::22f])
        by mx.google.com with ESMTPS id r9si9621627ybd.41.2016.11.24.05.11.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Nov 2016 05:11:54 -0800 (PST)
Received: by mail-yw0-x22f.google.com with SMTP id i145so38934356ywg.2
        for <linux-mm@kvack.org>; Thu, 24 Nov 2016 05:11:54 -0800 (PST)
MIME-Version: 1.0
From: =?UTF-8?B?0JDQtNGL0LPQttGLINCe0L3QtNCw0YA=?= <ondar07@gmail.com>
Date: Thu, 24 Nov 2016 16:11:53 +0300
Message-ID: <CAPhj7_CW_X5UuLPUfUFEA0mfPB_6OSO195ZQokckGOZzJevyyw@mail.gmail.com>
Subject: [PATCH] mm/oom_kill.c: fix initial value of victim_points variable
Content-Type: multipart/alternative; boundary=001a114fcfc2d28d4405420bbf2b
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

--001a114fcfc2d28d4405420bbf2b
Content-Type: text/plain; charset=UTF-8

If the initial value of victim_points variable is equal to 0,
oom killer may choose a victim incorrectly.
For example, parent points > 0, 0 < child_points < parent points
(chosen_points).
In this example, current oom killer chooses this child, not parent.

To apply the patch, in the root of a kernel tree use:
patch -p1 <this_fix.patch

Signed-off-by: Adygzhy Ondar <ondar07@gmail.com>

------------------------------------------------------------------------------------
--- linux/mm/oom_kill.c.orig 2016-11-24 15:03:43.711235386 +0300
+++ linux/mm/oom_kill.c 2016-11-24 15:04:00.851942474 +0300
@@ -812,7 +812,7 @@ static void oom_kill_process(struct oom_
  struct task_struct *child;
  struct task_struct *t;
  struct mm_struct *mm;
- unsigned int victim_points = 0;
+ unsigned int victim_points = points;
  static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
       DEFAULT_RATELIMIT_BURST);
  bool can_oom_reap = true;

--001a114fcfc2d28d4405420bbf2b
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div>If the initial value of victim_points variable is equ=
al to 0,<br>oom killer may choose a victim incorrectly.<br>For example, par=
ent points &gt; 0, 0 &lt; child_points &lt; parent points (chosen_points).<=
br>In this example, current oom killer chooses this child, not parent.</div=
><br><div>To apply the patch, in the root of a kernel tree use:</div><div>p=
atch -p1 &lt;this_fix.patch</div><div><br></div><div>Signed-off-by: Adygzhy=
 Ondar &lt;<a href=3D"mailto:ondar07@gmail.com">ondar07@gmail.com</a>&gt;</=
div><div><br></div><div>---------------------------------------------------=
---------------------------------</div><div><div>--- linux/mm/oom_kill.c.or=
ig<span class=3D"gmail-Apple-tab-span" style=3D"white-space:pre">	</span>20=
16-11-24 15:03:43.711235386 +0300</div><div>+++ linux/mm/oom_kill.c<span cl=
ass=3D"gmail-Apple-tab-span" style=3D"white-space:pre">	</span>2016-11-24 1=
5:04:00.851942474 +0300</div><div>@@ -812,7 +812,7 @@ static void oom_kill_=
process(struct oom_</div><div>=C2=A0<span class=3D"gmail-Apple-tab-span" st=
yle=3D"white-space:pre">	</span>struct task_struct *child;</div><div>=C2=A0=
<span class=3D"gmail-Apple-tab-span" style=3D"white-space:pre">	</span>stru=
ct task_struct *t;</div><div>=C2=A0<span class=3D"gmail-Apple-tab-span" sty=
le=3D"white-space:pre">	</span>struct mm_struct *mm;</div><div>-<span class=
=3D"gmail-Apple-tab-span" style=3D"white-space:pre">	</span>unsigned int vi=
ctim_points =3D 0;</div><div>+<span class=3D"gmail-Apple-tab-span" style=3D=
"white-space:pre">	</span>unsigned int victim_points =3D points;</div><div>=
=C2=A0<span class=3D"gmail-Apple-tab-span" style=3D"white-space:pre">	</spa=
n>static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,</div><d=
iv>=C2=A0<span class=3D"gmail-Apple-tab-span" style=3D"white-space:pre">			=
		</span> =C2=A0 =C2=A0 =C2=A0DEFAULT_RATELIMIT_BURST);</div><div>=C2=A0<sp=
an class=3D"gmail-Apple-tab-span" style=3D"white-space:pre">	</span>bool ca=
n_oom_reap =3D true;</div></div></div>

--001a114fcfc2d28d4405420bbf2b--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
