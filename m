Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 6ED4F6B0092
	for <linux-mm@kvack.org>; Wed, 16 May 2012 05:03:19 -0400 (EDT)
Received: by obbwd18 with SMTP id wd18so1074057obb.14
        for <linux-mm@kvack.org>; Wed, 16 May 2012 02:03:18 -0700 (PDT)
MIME-Version: 1.0
Date: Wed, 16 May 2012 14:33:18 +0530
Message-ID: <CAD5x=MPcwXyy0eOdqPxc_8K_i3enoU3ZbtwLS71SHR58FCT6rg@mail.gmail.com>
Subject: [bug] shrink_slab shrinkersize handling
From: solmac john <johnsolmac@gmail.com>
Content-Type: multipart/alternative; boundary=e89a8ff1c0461e00e604c02397f0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Kernelnewbies@kernelnewbies.org, linux-kernel@vger.kernel.org

--e89a8ff1c0461e00e604c02397f0
Content-Type: text/plain; charset=ISO-8859-1

Hi All,

During mm performance testing sometimes I observed below kernel messages

[   80.776000] shrink_slab: ashmem_shrink+0x0/0x114 negative objects to
delete nr=-2133936901
[   80.784000] shrink_slab: ashmem_shrink+0x0/0x114 negative objects to
delete nr=-2139256767
[   80.796000] shrink_slab: ashmem_shrink+0x0/0x114 negative objects to
delete nr=-2079333971
[   80.804000] shrink_slab: ashmem_shrink+0x0/0x114 negative objects to
delete nr=-2096156269
[   80.812000] shrink_slab: ashmem_shrink+0x0/0x114 negative objects to
delete nr=-20658392

 After debugging is I fount these prints from mm/vmscan.c
Kernel Error msg point

   unsigned long total_scan;

               unsigned long max_pass;

                max_pass = do_shrinker_shrink(shrinker, shrink, 0);

                delta = (4 * nr_pages_scanned) / shrinker->seeks;

                delta *= max_pass;

                do_div(delta, lru_pages + 1);

                shrinker->nr += delta;

                if (shrinker->nr < 0) {

                        printk(KERN_ERR "shrink_slab: %pF negative objects
to "

                               "delete nr=%ld\n",

                               shrinker->shrink, shrinker->nr);

                        shrinker->nr = max_pass;
                }



I found one patch  http://lkml.org/lkml/2011/8/22/80    for this fix
Please let me know reason why I am getting above error and above is really
fix for this problem.  ?
I am working on ARM cortex A9  linux-3.0.20 kernel.

Thanks,
John

--e89a8ff1c0461e00e604c02397f0
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<p style=3D"MARGIN:0in 0in 10pt" class=3D"MsoNormal"><font size=3D"3" face=
=3D"Calibri">Hi All, </font></p>
<p style=3D"MARGIN:0in 0in 10pt" class=3D"MsoNormal"><font size=3D"3" face=
=3D"Calibri">During mm performance testing sometimes I observed below kerne=
l messages</font></p>
<p style=3D"MARGIN:0in 0in 10pt" class=3D"MsoNormal"><font size=3D"3" face=
=3D"Calibri">[=A0=A0 80.776000] shrink_slab: ashmem_shrink+0x0/0x114 negati=
ve objects to delete nr=3D-2133936901<br>[=A0=A0 80.784000] shrink_slab: as=
hmem_shrink+0x0/0x114 negative objects to delete nr=3D-2139256767<br>
[=A0=A0 80.796000] shrink_slab: ashmem_shrink+0x0/0x114 negative objects to=
 delete nr=3D-2079333971<br>[=A0=A0 80.804000] shrink_slab: ashmem_shrink+0=
x0/0x114 negative objects to delete nr=3D-2096156269<br>[=A0=A0 80.812000] =
shrink_slab: ashmem_shrink+0x0/0x114 negative objects to delete nr=3D-20658=
392=A0=A0=A0 </font></p>

<p style=3D"MARGIN:0in 0in 10pt" class=3D"MsoNormal"><font size=3D"3" face=
=3D"Calibri">=A0After debugging is I fount these prints from mm/vmscan.c </=
font></p>
<div style=3D"MARGIN:0in 0in 10pt" class=3D"MsoNormal"><font size=3D"3" fac=
e=3D"Calibri">Kernel Error msg point </font></div>
<p style=3D"TEXT-INDENT:0.5in;MARGIN:0in 0in 0pt" class=3D"MsoNormal"><font=
 size=3D"3" face=3D"Calibri">=A0=A0 unsigned long total_scan;</font></p>
<p style=3D"MARGIN:0in 0in 0pt" class=3D"MsoNormal"><font size=3D"3"><font =
face=3D"Calibri"><span style>=A0</span><span style>=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0 </span>unsigned long max_pass;</font></font></p>
<p style=3D"MARGIN:0in 0in 0pt" class=3D"MsoNormal"><font size=3D"3"><font =
face=3D"Calibri"><span style>=A0</span><span style>=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0 </span>max_pass =3D do_shrinker_shrink(shrinker, shrink,=
 0);</font></font></p>
<p style=3D"MARGIN:0in 0in 0pt" class=3D"MsoNormal"><font size=3D"3"><font =
face=3D"Calibri"><span style>=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 =
</span>delta =3D (4 * nr_pages_scanned) / shrinker-&gt;seeks;</font></font>=
</p>
<p style=3D"MARGIN:0in 0in 0pt" class=3D"MsoNormal"><font size=3D"3"><font =
face=3D"Calibri"><span style>=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 =
</span>delta *=3D max_pass;</font></font></p>
<p style=3D"MARGIN:0in 0in 0pt" class=3D"MsoNormal"><font size=3D"3"><font =
face=3D"Calibri"><span style>=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 =
</span>do_div(delta, lru_pages + 1);</font></font></p>
<p style=3D"MARGIN:0in 0in 0pt" class=3D"MsoNormal"><font size=3D"3"><font =
face=3D"Calibri"><span style>=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 =
</span>shrinker-&gt;nr +=3D delta;</font></font></p>
<p style=3D"MARGIN:0in 0in 0pt" class=3D"MsoNormal"><font size=3D"3"><font =
face=3D"Calibri"><span style>=A0 </span><span style>=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0</span>if (shrinker-&gt;nr &lt; 0) {</font></font></p>
<p style=3D"MARGIN:0in 0in 0pt" class=3D"MsoNormal"><font size=3D"3"><font =
face=3D"Calibri"><span style>=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0 </span>printk(KERN_ERR &quot;shrink_slab: %pF nega=
tive objects to &quot;</font></font></p>
<p style=3D"MARGIN:0in 0in 0pt" class=3D"MsoNormal"><font size=3D"3"><font =
face=3D"Calibri"><span style>=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 </span>&quot;delete nr=3D%ld\=
n&quot;,</font></font></p>
<p style=3D"MARGIN:0in 0in 0pt" class=3D"MsoNormal"><font size=3D"3"><font =
face=3D"Calibri"><span style>=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 </span>shrinker-&gt;shrink, s=
hrinker-&gt;nr);</font></font></p>
<p style=3D"MARGIN:0in 0in 0pt" class=3D"MsoNormal"><font size=3D"3"><font =
face=3D"Calibri"><span style>=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0 </span>shrinker-&gt;nr =3D max_pass;</font></font>=
</p>
<div style=3D"MARGIN:0in 0in 0pt" class=3D"MsoNormal"><font size=3D"3"><fon=
t face=3D"Calibri"><span style>=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0 </span>}</font></font></div>
<div style=3D"MARGIN:0in 0in 0pt" class=3D"MsoNormal"><font size=3D"3" face=
=3D"Calibri"></font>=A0</div>
<p style=3D"MARGIN:0in 0in 10pt" class=3D"MsoNormal"><font size=3D"3"><font=
 face=3D"Calibri"><span style></span></font></font>=A0</p>
<div style=3D"MARGIN:0in 0in 10pt" class=3D"MsoNormal"><font size=3D"3"><fo=
nt face=3D"Calibri">I found one patch <span style>=A0</span></font></font><=
a href=3D"http://lkml.org/lkml/2011/8/22/80"><font size=3D"3" face=3D"Calib=
ri">http://lkml.org/lkml/2011/8/22/80</font></a><font size=3D"3" face=3D"Ca=
libri">=A0=A0 <span style>=A0</span>for this fix <br>
</font></div>
<div style=3D"MARGIN:0in 0in 10pt" class=3D"MsoNormal"><font size=3D"3" fac=
e=3D"Calibri">Please let me know reason why I am getting above error and ab=
ove is really fix for this problem. <span style>=A0</span>?</font></div>
<div style=3D"MARGIN:0in 0in 10pt" class=3D"MsoNormal"><font face=3D"Calibr=
i"><font size=3D"3">I am working on=A0</font><span style=3D"LINE-HEIGHT:115=
%;FONT-SIZE:10pt">ARM cortex A9=A0</span><font size=3D"3">=A0linux-3.0.20 k=
ernel. </font></font></div>

<div style=3D"MARGIN:0in 0in 10pt" class=3D"MsoNormal"><font size=3D"3" fac=
e=3D"Calibri"></font>=A0</div>
<div style=3D"MARGIN:0in 0in 10pt" class=3D"MsoNormal"><font size=3D"3" fac=
e=3D"Calibri">Thanks, </font></div>
<div style=3D"MARGIN:0in 0in 10pt" class=3D"MsoNormal"><font size=3D"3" fac=
e=3D"Calibri">John</font></div>
<p>=A0</p>

--e89a8ff1c0461e00e604c02397f0--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
