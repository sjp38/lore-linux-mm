Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id B8C016B015F
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 04:03:18 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so9534131pbb.14
        for <linux-mm@kvack.org>; Tue, 26 Jun 2012 01:03:18 -0700 (PDT)
MIME-Version: 1.0
Date: Tue, 26 Jun 2012 13:33:17 +0530
Message-ID: <CADArhcAxf3g=SLgDaJJMpzNpL_X7fbVbL1jzBYiyjPQFxXLYTA@mail.gmail.com>
Subject: ashmem_shrink with long term stable kernel [3.0.36]
From: Akhilesh Kumar <akhilesh.lxr@gmail.com>
Content-Type: multipart/alternative; boundary=047d7b2ee07dff758f04c35b87f7
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: khlebnikov@openvz.org, david@fromorbit.com, akpm@linux-foundation.org, mgorman@suse.de, riel@redhat.com, minchan.kim@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

--047d7b2ee07dff758f04c35b87f7
Content-Type: text/plain; charset=ISO-8859-1

Hi All,

During mm performance testing sometimes we observed below kernel messages

shrink_slab: ashmem_shrink+0x0/0x114 negative objects to delete
nr=-2133936901
shrink_slab: ashmem_shrink+0x0/0x114 negative objects to delete
nr=-2139256767
shrink_slab: ashmem_shrink+0x0/0x114 negative objects to delete
nr=-2079333971
shrink_slab: ashmem_shrink+0x0/0x114 negative objects to delete
nr=-2096156269
shrink_slab: ashmem_shrink+0x0/0x114 negative objects to delete
nr=-20658392
 After debugging is we fount below patch mm/vmscan
http://git.kernel.org/?p=linux/kernel/git/stable/linux-stable.git;a=commitdiff;h=635697c663f38106063d5659f0cf2e45afcd4bb5


Since patch fix critical issue and same is not integrated with long term
stable kernel (3.0.36)
and  we are using below patch with long term stable kernel (3.0.36) is
there any side effects ?
@@ -248,10 +248,12 @@ unsigned long shrink_slab(struct shrink_control
*shrink,

        list_for_each_entry(shrinker, &shrinker_list, list) {
                unsigned long long delta;
-               unsigned long total_scan;
-               unsigned long max_pass;
+               long total_scan;
+               long max_pass;

                max_pass = do_shrinker_shrink(shrinker, shrink, 0);
+               if (max_pass <= 0)
+                       continue;
                delta = (4 * nr_pages_scanned) / shrinker->seeks;
                delta *= max_pass;
                do_div(delta, lru_pages + 1);
-- 
Please review and share ur comments.

Thanks,
Akhilesh

--047d7b2ee07dff758f04c35b87f7
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<p style=3D"MARGIN:0in 0in 10pt" class=3D"MsoNormal"><font size=3D"3" face=
=3D"Calibri">Hi All, </font></p>
<p style=3D"MARGIN:0in 0in 10pt" class=3D"MsoNormal"><font size=3D"3" face=
=3D"Calibri">During mm performance testing sometimes=A0we observed below ke=
rnel messages</font></p>
<p style=3D"MARGIN:0in 0in 10pt" class=3D"MsoNormal"><font size=3D"3" face=
=3D"Calibri">shrink_slab: ashmem_shrink+0x0/0x114 negative objects to delet=
e nr=3D-2133936901<br>shrink_slab: ashmem_shrink+0x0/0x114 negative objects=
 to delete nr=3D-2139256767<br>
shrink_slab: ashmem_shrink+0x0/0x114 negative objects to delete nr=3D-20793=
33971<br>shrink_slab: ashmem_shrink+0x0/0x114 negative objects to delete nr=
=3D-2096156269<br>shrink_slab: ashmem_shrink+0x0/0x114 negative objects to =
delete nr=3D-20658392=A0=A0=A0 </font></p>

<div style=3D"MARGIN:0in 0in 10pt" class=3D"MsoNormal"><font size=3D"3" fac=
e=3D"Calibri">=A0After debugging is=A0we fount=A0below patch=A0mm/vmscan </=
font></div>
<div style=3D"MARGIN:0in 0in 10pt" class=3D"MsoNormal"><font size=3D"3"><a =
href=3D"http://git.kernel.org/?p=3Dlinux/kernel/git/stable/linux-stable.git=
;a=3Dcommitdiff;h=3D635697c663f38106063d5659f0cf2e45afcd4bb5"><span style>h=
ttp://git.kernel.org/?p=3Dlinux/kernel/git/stable/linux-stable.git;a=3Dcomm=
itdiff;h=3D635697c663f38106063d5659f0cf2e45afcd4bb5</span></a><span style>=
=A0=A0=A0 </span></font></div>

<div style=3D"MARGIN:0in 0in 10pt" class=3D"MsoNormal"><font size=3D"3" fac=
e=3D"Calibri"></font>=A0</div>
<div style=3D"MARGIN:0in 0in 10pt" class=3D"MsoNormal"><font size=3D"3" fac=
e=3D"Calibri">Since patch fix critical issue and same is not integrated wit=
h long term stable kernel (3.0.36)</font></div>
<div style=3D"MARGIN:0in 0in 10pt" class=3D"MsoNormal"><font size=3D"3" fac=
e=3D"Calibri">and=A0=A0we=A0are using=A0below patch with long term stable k=
ernel (3.0.36) is there any side effects ?=A0</font></div>
<div style=3D"MARGIN:0in 0in 10pt" class=3D"MsoNormal">@@ -248,10 +248,12 @=
@ unsigned long shrink_slab(struct shrink_control *shrink,<br>=A0<br>=A0=A0=
=A0=A0=A0=A0=A0 list_for_each_entry(shrinker, &amp;shrinker_list, list) {<b=
r>=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 unsigned long long delta;<b=
r>
-=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 unsigned long total_scan;<br>-=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 unsigned long max_pass;<br>+=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 long total_scan;<br>+=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 long max_pass;<br>=A0<br>=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0 max_pass =3D do_shrinker_shrink(shrinker, shrin=
k, 0);<br>
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 if (max_pass &lt;=3D 0)<br>+=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 continue;<b=
r>=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 delta =3D (4 * nr_pages_sca=
nned) / shrinker-&gt;seeks;<br>=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0 delta *=3D max_pass;<br>=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 d=
o_div(delta, lru_pages + 1);<br>
-- </div>
<div style=3D"MARGIN:0in 0in 10pt" class=3D"MsoNormal">Please review and sh=
are ur comments.=A0</div>
<div style=3D"MARGIN:0in 0in 10pt" class=3D"MsoNormal">=A0</div>
<div style=3D"MARGIN:0in 0in 10pt" class=3D"MsoNormal">Thanks,=A0</div>
<div style=3D"MARGIN:0in 0in 10pt" class=3D"MsoNormal">Akhilesh =A0</div>

--047d7b2ee07dff758f04c35b87f7--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
