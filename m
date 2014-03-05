Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f177.google.com (mail-qc0-f177.google.com [209.85.216.177])
	by kanga.kvack.org (Postfix) with ESMTP id 931B56B0035
	for <linux-mm@kvack.org>; Wed,  5 Mar 2014 17:21:02 -0500 (EST)
Received: by mail-qc0-f177.google.com with SMTP id w7so1925116qcr.8
        for <linux-mm@kvack.org>; Wed, 05 Mar 2014 14:21:02 -0800 (PST)
Received: from mail-qa0-x22d.google.com (mail-qa0-x22d.google.com [2607:f8b0:400d:c00::22d])
        by mx.google.com with ESMTPS id o92si2019067qgd.107.2014.03.05.14.21.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 05 Mar 2014 14:21:01 -0800 (PST)
Received: by mail-qa0-f45.google.com with SMTP id hw13so1678049qab.18
        for <linux-mm@kvack.org>; Wed, 05 Mar 2014 14:21:01 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1393625931-2858-1-git-send-email-quning@google.com>
References: <1393625931-2858-1-git-send-email-quning@google.com>
From: Ning Qu <quning@google.com>
Date: Wed, 5 Mar 2014 14:20:41 -0800
Message-ID: <CACz4_2eYUOkHdOtBJGDGMMwBcQkyPs8BDXQ491Ab_ig4z8q5mQ@mail.gmail.com>
Subject: Re: [PATCH 0/1] mm, shmem: map few pages around fault address if they
 are in page cache
Content-Type: multipart/alternative; boundary=001a1139b8768f30e004f3e36f23
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Chinner <david@fromorbit.com>, Ning Qu <quning@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Ning Qu <quning@google.com>

--001a1139b8768f30e004f3e36f23
Content-Type: text/plain; charset=UTF-8

Sorry for the delay, here comes the new results from usemem which Kirill
used in the previous patch.

Tested on Xeon machine with 64GiB of RAM, using the current default fault order
4.

Sequential access 16GiB file
                                Baseline          with-patch
1 thread
    minor fault           4,194,406             262,194
    time, seconds              6.38                  5.08

8 thread
    minor fault         33,554,768          3,466,150
    time, seconds            10.92                 7.33

32 thread
    minor fault       134,220,140          8,450,265
    time, seconds           40.77                34.24

60 thread
    minor fault       251,661,943        15,790,478
    time, seconds           77.23                65.19

120 thread
    minor fault       503,330,421        31,578,717
    time, seconds          143.11              130.58

Random access 16GiB file
                                Baseline          with-patch
1 thread
    minor fault              263,568             16,667
    time, seconds            10.08               10.57

8 thread
    minor fault           2,097,700            184,134
    time, seconds            13.65               13.66

32 thread
    minor fault          8,389,948             579,089
    time, seconds           39.44                38.56

60 thread
    minor fault        15,733,099           1,019,478
    time, seconds           73.67                 72.63

120 thread
    minor fault        31,467,940           2,009,898
    time, seconds         148.48                145.81

--001a1139b8768f30e004f3e36f23
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div><span style=3D"font-family:arial,sans-serif;font-size=
:13px">Sorry for the delay, here comes the new results from usemem which Ki=
rill used in the previous patch.</span></div><div><span style=3D"font-famil=
y:arial,sans-serif;font-size:13px"><br>

</span></div><span style=3D"font-family:arial,sans-serif;font-size:13px">Te=
sted on Xeon machine with 64GiB of RAM, using the current default fault=C2=
=A0</span><span style=3D"font-family:arial,sans-serif;font-size:13px">order=
 4.</span><br style=3D"font-family:arial,sans-serif;font-size:13px">











<br style=3D"font-family:arial,sans-serif;font-size:13px"><span style=3D"fo=
nt-family:arial,sans-serif;font-size:13px">Sequential access 16GiB file</sp=
an><br style=3D"font-family:arial,sans-serif;font-size:13px"><span style=3D=
"font-family:arial,sans-serif;font-size:13px">=C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 Baseline =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0with-patch</span><br =
style=3D"font-family:arial,sans-serif;font-size:13px">











<span style=3D"font-family:arial,sans-serif;font-size:13px">1 thread</span>=
<br style=3D"font-family:arial,sans-serif;font-size:13px"><span style=3D"fo=
nt-family:arial,sans-serif;font-size:13px">=C2=A0 =C2=A0 minor fault =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 4,194,406 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 262,194</span><br style=3D"font-family:arial,sans-serif;font-size:13=
px">











<span style=3D"font-family:arial,sans-serif;font-size:13px">=C2=A0 =C2=A0 t=
ime, seconds =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A06.38 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A05.08</span><br style=
=3D"font-family:arial,sans-serif;font-size:13px"><br><span style=3D"font-si=
ze:13px;font-family:arial,sans-serif">8 thread</span><br style=3D"font-size=
:13px;font-family:arial,sans-serif">











<span style=3D"font-size:13px;font-family:arial,sans-serif">=C2=A0 =C2=A0 m=
inor fault =C2=A0 =C2=A0 =C2=A0 =C2=A0 33,554,768 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A03,466,150</span><br style=3D"font-size:13px;font-family:arial,san=
s-serif"><span style=3D"font-size:13px;font-family:arial,sans-serif">=C2=A0=
 =C2=A0 time, seconds =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A010.92 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 7.33</span><div>











<br></div><div><span style=3D"font-size:13px;font-family:arial,sans-serif">=
32 thread</span><br style=3D"font-size:13px;font-family:arial,sans-serif"><=
span style=3D"font-size:13px;font-family:arial,sans-serif">=C2=A0 =C2=A0 mi=
nor fault =C2=A0 =C2=A0 =C2=A0 134,220,140 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A08,450,265</span><br style=3D"font-size:13px;font-family:arial,sans-serif=
">











<span style=3D"font-size:13px;font-family:arial,sans-serif">=C2=A0 =C2=A0 t=
ime, seconds =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 40.77 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A034.24</span></div><div><br></div><div><sp=
an style=3D"font-size:13px;font-family:arial,sans-serif">60 thread</span><b=
r style=3D"font-size:13px;font-family:arial,sans-serif">











<span style=3D"font-size:13px;font-family:arial,sans-serif">=C2=A0 =C2=A0 m=
inor fault =C2=A0 =C2=A0 =C2=A0 251,661,943 =C2=A0 =C2=A0 =C2=A0 =C2=A015,7=
90,478</span><br style=3D"font-size:13px;font-family:arial,sans-serif"><spa=
n style=3D"font-size:13px;font-family:arial,sans-serif">=C2=A0 =C2=A0 time,=
 seconds =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 77.23 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A065.19</span></div>











<div><br></div><div><div><span style=3D"font-size:13px;font-family:arial,sa=
ns-serif">120 thread</span><br style=3D"font-size:13px;font-family:arial,sa=
ns-serif"><span style=3D"font-size:13px;font-family:arial,sans-serif">=C2=
=A0 =C2=A0 minor fault =C2=A0 =C2=A0 =C2=A0 503,330,421 =C2=A0 =C2=A0 =C2=
=A0 =C2=A031,578,717</span><br style=3D"font-size:13px;font-family:arial,sa=
ns-serif">











<span style=3D"font-size:13px;font-family:arial,sans-serif">=C2=A0 =C2=A0 t=
ime, seconds =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0143.11 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0130.58</span></div><div><span style=3D"font-size=
:13px;font-family:arial,sans-serif"><br></span></div><span style=3D"font-fa=
mily:arial,sans-serif;font-size:13px">Random access 16GiB file</span><br st=
yle=3D"font-family:arial,sans-serif;font-size:13px">











<span style=3D"font-size:13px;font-family:arial,sans-serif">=C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 Baseline =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0with-pa=
tch</span><br style=3D"font-size:13px;font-family:arial,sans-serif"><span s=
tyle=3D"font-size:13px;font-family:arial,sans-serif">1 thread</span><br sty=
le=3D"font-size:13px;font-family:arial,sans-serif">









<span style=3D"font-size:13px;font-family:arial,sans-serif">=C2=A0 =C2=A0 m=
inor fault =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0263,568 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 16,667</span><br style=3D"font-size:13px=
;font-family:arial,sans-serif"><span style=3D"font-size:13px;font-family:ar=
ial,sans-serif">=C2=A0 =C2=A0 time, seconds =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A010.08 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 10.57</spa=
n><br style=3D"font-size:13px;font-family:arial,sans-serif">









<br><span style=3D"font-size:13px;font-family:arial,sans-serif">8 thread</s=
pan><br style=3D"font-size:13px;font-family:arial,sans-serif"><span style=
=3D"font-size:13px;font-family:arial,sans-serif">=C2=A0 =C2=A0 minor fault =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 2,097,700 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0184,134</span><br style=3D"font-size:13px;font-family:arial,sa=
ns-serif">









<span style=3D"font-size:13px;font-family:arial,sans-serif">=C2=A0 =C2=A0 t=
ime, seconds =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A013.65 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 13.66</span><div><br></div><div><span st=
yle=3D"font-size:13px;font-family:arial,sans-serif">32 thread</span><br sty=
le=3D"font-size:13px;font-family:arial,sans-serif">









<span style=3D"font-size:13px;font-family:arial,sans-serif">=C2=A0 =C2=A0 m=
inor fault =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A08,389,948 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 579,089</span><br style=3D"font-size:13px;font-family=
:arial,sans-serif"><span style=3D"font-size:13px;font-family:arial,sans-ser=
if">=C2=A0 =C2=A0 time, seconds =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 39.44 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A038.56</span></div>









<div><br></div><div><span style=3D"font-size:13px;font-family:arial,sans-se=
rif">60 thread</span><br style=3D"font-size:13px;font-family:arial,sans-ser=
if"><span style=3D"font-size:13px;font-family:arial,sans-serif">=C2=A0 =C2=
=A0 minor fault =C2=A0 =C2=A0 =C2=A0 =C2=A015,733,099 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 1,019,478</span><br style=3D"font-size:13px;font-family:arial=
,sans-serif">









<span style=3D"font-size:13px;font-family:arial,sans-serif">=C2=A0 =C2=A0 t=
ime, seconds =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 73.67 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 72.63</span></div><div><br></div><div><s=
pan style=3D"font-size:13px;font-family:arial,sans-serif">120 thread</span>=
<br style=3D"font-size:13px;font-family:arial,sans-serif">









<span style=3D"font-size:13px;font-family:arial,sans-serif">=C2=A0 =C2=A0 m=
inor fault =C2=A0 =C2=A0 =C2=A0 =C2=A031,467,940 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 2,009,898</span><br style=3D"font-size:13px;font-family:arial,sa=
ns-serif"><span style=3D"font-size:13px;font-family:arial,sans-serif">=C2=
=A0 =C2=A0 time, seconds =C2=A0 =C2=A0 =C2=A0 =C2=A0 148.48 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0145.81</span></div>









<div class=3D"gmail_extra"><br></div></div></div>

--001a1139b8768f30e004f3e36f23--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
