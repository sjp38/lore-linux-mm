Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 9DA326B030A
	for <linux-mm@kvack.org>; Wed, 14 Dec 2011 15:13:23 -0500 (EST)
Received: by pbaa13 with SMTP id a13so1201171pba.14
        for <linux-mm@kvack.org>; Wed, 14 Dec 2011 12:13:22 -0800 (PST)
MIME-Version: 1.0
From: Laurent Chavey <chavey@google.com>
Date: Wed, 14 Dec 2011 12:12:41 -0800
Message-ID: <CAEas1LKNMSxhp-7DpsOOCu0fx6kx5ya-zqsZQgnf6JwzX0E0gw@mail.gmail.com>
Subject: question: why use vzalloc() and vzfree() in mem_cgroup_alloc() and mem_cgroup_free()
Content-Type: multipart/alternative; boundary=e89a8ff1c8c0e4afd404b412ffaf
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: LKML <linux-kernel@vger.kernel.org>, laurent chavey <chavey@google.com>, glommer@parallels.com

--e89a8ff1c8c0e4afd404b412ffaf
Content-Type: text/plain; charset=ISO-8859-1

context:

While testing patches from Glauber Costa, "adding support
for tcp memory allocation in kmem cgroup", we hit a
BUG_ON(in_interrupt()) in vfree(). The code path in question
is taken because the izeof(struct mem_cgroup) is
>= PAGE_SIZE in the call to mem_cgroup_free(),

Since socket may get free in an interrupt context,
the combination of vzalloc(), vfree() should not be used
when accounting for socket mem (unless the code is modified).

question:

Is there reasons why vzalloc() is used in mem_cgroup_alloc() ?
    . are we seeing mem fragmentations to level that fail
      kzalloc() or kmalloc().
    . do we have empirical data that shows the allocation failure
      rate for kmalloc(), kzalloc() per alloc size (num pages)

--e89a8ff1c8c0e4afd404b412ffaf
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div><span class=3D"Apple-style-span" style=3D"font-family:&#39;courier new=
&#39;,monospace">context:</span></div><div><span class=3D"Apple-style-span"=
 style=3D"font-family:&#39;courier new&#39;,monospace"><br></span></div><di=
v><span class=3D"Apple-style-span" style=3D"font-family:&#39;courier new&#3=
9;,monospace">While testing patches from Glauber Costa, &quot;adding suppor=
t</span></div>

<div><font class=3D"Apple-style-span" face=3D"&#39;courier new&#39;, monosp=
ace">for tcp memory allocation</font>=A0<span class=3D"Apple-style-span" st=
yle=3D"font-family:&#39;courier new&#39;,monospace">in kmem cgroup&quot;, w=
e hit a</span></div>

<div><span class=3D"Apple-style-span" style=3D"font-family:&#39;courier new=
&#39;,monospace">BUG_ON(in_interrupt()) in vfree(). The code path in questi=
on</span><div><font class=3D"Apple-style-span" face=3D"&#39;courier new&#39=
;, monospace">is taken because the=A0</font><span class=3D"Apple-style-span=
" style=3D"font-family:&#39;courier new&#39;,monospace">izeof(struct mem_cg=
roup) is</span><font class=3D"Apple-style-span" face=3D"&#39;courier new&#3=
9;, monospace"><br>

</font><span class=3D"Apple-style-span" style=3D"font-family:&#39;courier n=
ew&#39;,monospace">&gt;=3D PAGE_SIZE=A0</span><font class=3D"Apple-style-sp=
an" face=3D"&#39;courier new&#39;, monospace">in the call to=A0</font><span=
 class=3D"Apple-style-span" style=3D"font-family:&#39;courier new&#39;,mono=
space">mem_cgroup_free(),=A0</span></div>

<div><font class=3D"Apple-style-span" face=3D"&#39;courier new&#39;, monosp=
ace"><br></font></div><div><font class=3D"Apple-style-span" face=3D"&#39;co=
urier new&#39;, monospace">Since socket may get free in an interrupt contex=
t,</font></div>

<div><font class=3D"Apple-style-span" face=3D"&#39;courier new&#39;, monosp=
ace">the combination of vzalloc(), vfree() should not be used</font></div><=
/div><div><font class=3D"Apple-style-span" face=3D"&#39;courier new&#39;, m=
onospace">when accounting for socket mem (unless the code is modified).</fo=
nt></div>

<div><span class=3D"Apple-style-span" style=3D"font-family:&#39;courier new=
&#39;,monospace"><br></span></div><div><span class=3D"Apple-style-span" sty=
le=3D"font-family:&#39;courier new&#39;,monospace">question:</span></div><d=
iv>
<span class=3D"Apple-style-span" style=3D"font-family:&#39;courier new&#39;=
,monospace"><br>
</span></div><div><span class=3D"Apple-style-span" style=3D"font-family:&#3=
9;courier new&#39;,monospace">Is there reasons why vzalloc() is used in mem=
_cgroup_alloc() ?</span></div><div><span class=3D"Apple-style-span" style=
=3D"font-family:&#39;courier new&#39;,monospace">=A0 =A0 . are we seeing me=
m fragmentations to level that fail</span></div>

<div><span class=3D"Apple-style-span" style=3D"font-family:&#39;courier new=
&#39;,monospace">=A0 =A0 =A0 kzalloc() or kmalloc().=A0</span></div><div><f=
ont class=3D"Apple-style-span" face=3D"&#39;courier new&#39;, monospace">=
=A0 =A0 . do we have=A0empirical=A0data that shows the allocation failure</=
font></div>

<div><font class=3D"Apple-style-span" face=3D"&#39;courier new&#39;, monosp=
ace">=A0 =A0 =A0 rate for kmalloc(), kzalloc() per alloc size (num pages)</=
font></div><div><span class=3D"Apple-style-span" style=3D"font-family:&#39;=
courier new&#39;,monospace">=A0 =A0 =A0=A0</span></div>

<div><span class=3D"Apple-style-span" style=3D"font-family:&#39;courier new=
&#39;,monospace"><br></span></div>

--e89a8ff1c8c0e4afd404b412ffaf--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
