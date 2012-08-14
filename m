Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 47D5B6B005A
	for <linux-mm@kvack.org>; Tue, 14 Aug 2012 05:59:44 -0400 (EDT)
Received: by vbkv13 with SMTP id v13so220823vbk.14
        for <linux-mm@kvack.org>; Tue, 14 Aug 2012 02:59:43 -0700 (PDT)
MIME-Version: 1.0
Date: Tue, 14 Aug 2012 15:29:42 +0530
Message-ID: <CAB5gotsB--4JhGqhXJEhu3TTTDEev_YxLN-r6UA+N7uFMiZHyA@mail.gmail.com>
Subject: 
From: vaibhav shinde <v.bhav.shinde@gmail.com>
Content-Type: multipart/alternative; boundary=047d7b5d9e6b90960f04c736dea4
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org, khlebnikov@openvz.org, david@fromorbit.com, akpm@linux-foundation.org, baramsori72@gmail.com, righi.andrea@gmail.com, mgorman@suse.de, riel@redhat.com, minchan.kim@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

--047d7b5d9e6b90960f04c736dea4
Content-Type: text/plain; charset=ISO-8859-1

 Hi all,

I am facing the same issue regarding cgroup block io behavior as mentioned
by Mr. Naveen in the below link
*http://lkml.org/lkml/2012/7/27/35*

I am testing using following tunnable parameters-

*              blkio.throttle.write_bps_device (set to different cgroups
depending on default readings)*
*              blkio.throttle.read_bps_device *
*              blkio.throttle.write_iops_device * *
*
*              blkio.throttle.read_iops_device * *
*
*              blkio.weight (range 100-1000)*

I tested once using a user level application that creates few processes
with two threads in each process.
The threads perform read and write operations using 'dd' command and
records the readings.

The readings achieved from above test appear unpredictable to me.

Can you suggest any method or testcase for analyzing the behavior of
 cgroup block io in case of threads.

Thanks in advance


Kind Regards,
Vaibhav Shinde
*
*

--047d7b5d9e6b90960f04c736dea4
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div>
<div><font>Hi all,</font><font><br></font></div></div><div><font><br></font=
></div><div><font>I am facing the same issue regarding cgroup block io beha=
vior as mentioned by Mr. Naveen in the below link</font><font><br></font></=
div>

<div><font><i><a href=3D"http://lkml.org/lkml/2012/7/27/35" target=3D"_blan=
k">http://lkml.org/lkml/2012/7/27/35</a></i><br></font></div><div><font><br=
></font></div><div><font>I am testing using following tunnable parameters-<=
br>
</font></div>
<div><font><br></font></div><div>
<div><b><span lang=3D"EN-US" style=3D"line-height:115%;font-size:11.0pt;fon=
t-family:&quot;Courier New&quot;">=A0 =A0 =A0 =A0 =A0 =A0 =A0 blkio.throttl=
e.write_bps_device (set to different cgroups depending on default readings)=
</span></b>
<font><br></font></div><div>
<b><span lang=3D"EN-US" style=3D"line-height:115%;font-size:11.0pt;font-fam=
ily:&quot;Courier New&quot;">=A0 =A0 =A0 =A0 =A0 =A0 =A0 blkio.throttle.rea=
d_bps_device=A0</span></b>
<font><br></font></div><div>
<b><span lang=3D"EN-US" style=3D"line-height:115%;font-size:11.0pt;font-fam=
ily:&quot;Courier New&quot;">=A0 =A0 =A0 =A0 =A0 =A0 =A0 blkio.throttle.wri=
te_iops_device=A0</span></b>
<b><span lang=3D"EN-US" style=3D"line-height:115%;font-size:11.0pt;font-fam=
ily:&quot;Courier New&quot;"><br></span></b></div><div>
<b><span lang=3D"EN-US" style=3D"line-height:115%;font-size:11.0pt;font-fam=
ily:&quot;Courier New&quot;">=A0 =A0 =A0 =A0 =A0 =A0 =A0 blkio.throttle.rea=
d_iops_device=A0</span></b>
<b><span lang=3D"EN-US" style=3D"line-height:115%;font-size:11.0pt;font-fam=
ily:&quot;Courier New&quot;"><br></span></b></div><div>
<b><span lang=3D"EN-US" style=3D"line-height:115%;font-size:11.0pt;font-fam=
ily:&quot;Courier New&quot;">=A0 =A0 =A0 =A0 =A0 =A0 =A0 blkio.weight (rang=
e 100-1000)</span></b></div><font><br></font></div><div><font>I tested once=
 using a user level application that creates few processes with two threads=
 in each process.</font><font><br>

</font></div><div><font>The threads perform read and write operations using=
 &#39;dd&#39; command and records the readings.<br></font></div><div><font>=
<br></font></div><div><font>The readings achieved from above test appear un=
predictable to me.<br>

</font></div><div><font><br></font></div><div><font>Can you suggest any met=
hod or testcase for analyzing the behavior of =A0cgroup block io in case of=
 threads.<br></font></div><div><font><br></font></div><div><font>Thanks in =
advance<br>

</font></div><div><font><br></font></div><div><font><br></font></div><div><=
font>Kind Regards,<br></font></div><div><font>Vaibhav Shinde<br></font></di=
v><div><b><span lang=3D"EN-US" style=3D"line-height:115%;font-size:11.0pt;f=
ont-family:&quot;Courier New&quot;"><br>

</span></b></div>

--047d7b5d9e6b90960f04c736dea4--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
