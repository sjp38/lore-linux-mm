Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f174.google.com (mail-vc0-f174.google.com [209.85.220.174])
	by kanga.kvack.org (Postfix) with ESMTP id A4DCE6B006E
	for <linux-mm@kvack.org>; Fri, 28 Feb 2014 17:36:10 -0500 (EST)
Received: by mail-vc0-f174.google.com with SMTP id im17so1405325vcb.33
        for <linux-mm@kvack.org>; Fri, 28 Feb 2014 14:36:10 -0800 (PST)
Received: from mail-ve0-x22e.google.com (mail-ve0-x22e.google.com [2607:f8b0:400c:c01::22e])
        by mx.google.com with ESMTPS id f5si815913vej.35.2014.02.28.14.36.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 28 Feb 2014 14:36:10 -0800 (PST)
Received: by mail-ve0-f174.google.com with SMTP id oz11so501566veb.33
        for <linux-mm@kvack.org>; Fri, 28 Feb 2014 14:36:09 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20140228143440.e0ec026baeced2efbb52aa50@linux-foundation.org>
References: <1393625931-2858-1-git-send-email-quning@google.com> <20140228143440.e0ec026baeced2efbb52aa50@linux-foundation.org>
From: Ning Qu <quning@google.com>
Date: Fri, 28 Feb 2014 14:35:28 -0800
Message-ID: <CACQD4-5ycbJmgZ_a7y-So=VvxCv0fMRPEExDqVUiJEYoOatC3g@mail.gmail.com>
Subject: Re: [PATCH 0/1] mm, shmem: map few pages around fault address if they
 are in page cache
Content-Type: multipart/alternative; boundary=001a1136516c7ca5f304f37f1029
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>

--001a1136516c7ca5f304f37f1029
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

let me double check.

Best wishes,
--=20
Ning Qu (=E6=9B=B2=E5=AE=81) | Software Engineer | quning@google.com | +1-4=
08-418-6066


On Fri, Feb 28, 2014 at 2:34 PM, Andrew Morton <akpm@linux-foundation.org>w=
rote:

> On Fri, 28 Feb 2014 14:18:50 -0800 Ning Qu <quning@google.com> wrote:
>
> > This is a follow-up patch for "mm: map few pages around fault address i=
f
> they are in page cache"
> >
> > We use the generic filemap_map_pages as ->map_pages in shmem/tmpfs.
> >
>
> Please cc Hugh on shmem/tmpfs things
>
> >
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > Below is just some simple experiment numbers from this patch, let me
> know if
> > you would like more:
> >
> > Tested on Xeon machine with 64GiB of RAM, using the current default fau=
lt
> > order 4.
> >
> > Sequential access 8GiB file
> >                       Baseline        with-patch
> > 1 thread
> >     minor fault               205             101
>
> Confused.  Sequential access of an 8G file should generate 2,000,000
> minor faults, not 205.  And with FAULT_AROUND_ORDER=3D4, that should come
> down to 2,000,000/16 minor faults when using faultaround?
>
> >     time, seconds     7.94            7.82
> >
> > Random access 8GiB file
> >                       Baseline        with-patch
> > 1 thread
> >     minor fault               724             623
> >     time, seconds     9.75            9.84
> >
>
>

--001a1136516c7ca5f304f37f1029
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">let me double check.</div><div class=3D"gmail_extra"><br c=
lear=3D"all"><div><div>Best wishes,</div><div><span style=3D"border-collaps=
e:collapse;font-family:arial,sans-serif;font-size:13px">--=C2=A0<br><span s=
tyle=3D"border-collapse:collapse;font-family:sans-serif;line-height:19px"><=
span style=3D"border-top-width:2px;border-right-width:0px;border-bottom-wid=
th:0px;border-left-width:0px;border-top-style:solid;border-right-style:soli=
d;border-bottom-style:solid;border-left-style:solid;border-top-color:rgb(21=
3,15,37);border-right-color:rgb(213,15,37);border-bottom-color:rgb(213,15,3=
7);border-left-color:rgb(213,15,37);padding-top:2px;margin-top:2px">Ning Qu=
 (=E6=9B=B2=E5=AE=81)<font color=3D"#555555">=C2=A0|</font></span><span sty=
le=3D"color:rgb(85,85,85);border-top-width:2px;border-right-width:0px;borde=
r-bottom-width:0px;border-left-width:0px;border-top-style:solid;border-righ=
t-style:solid;border-bottom-style:solid;border-left-style:solid;border-top-=
color:rgb(51,105,232);border-right-color:rgb(51,105,232);border-bottom-colo=
r:rgb(51,105,232);border-left-color:rgb(51,105,232);padding-top:2px;margin-=
top:2px">=C2=A0Software Engineer |</span><span style=3D"color:rgb(85,85,85)=
;border-top-width:2px;border-right-width:0px;border-bottom-width:0px;border=
-left-width:0px;border-top-style:solid;border-right-style:solid;border-bott=
om-style:solid;border-left-style:solid;border-top-color:rgb(0,153,57);borde=
r-right-color:rgb(0,153,57);border-bottom-color:rgb(0,153,57);border-left-c=
olor:rgb(0,153,57);padding-top:2px;margin-top:2px">=C2=A0<a href=3D"mailto:=
quning@google.com" style=3D"color:rgb(0,0,204)" target=3D"_blank">quning@go=
ogle.com</a>=C2=A0|</span><span style=3D"color:rgb(85,85,85);border-top-wid=
th:2px;border-right-width:0px;border-bottom-width:0px;border-left-width:0px=
;border-top-style:solid;border-right-style:solid;border-bottom-style:solid;=
border-left-style:solid;border-top-color:rgb(238,178,17);border-right-color=
:rgb(238,178,17);border-bottom-color:rgb(238,178,17);border-left-color:rgb(=
238,178,17);padding-top:2px;margin-top:2px">=C2=A0<a value=3D"+16502143877"=
 style=3D"color:rgb(0,0,204)">+1-408-418-6066</a></span></span></span></div=
>

</div>
<br><br><div class=3D"gmail_quote">On Fri, Feb 28, 2014 at 2:34 PM, Andrew =
Morton <span dir=3D"ltr">&lt;<a href=3D"mailto:akpm@linux-foundation.org" t=
arget=3D"_blank">akpm@linux-foundation.org</a>&gt;</span> wrote:<br><blockq=
uote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc =
solid;padding-left:1ex">

<div class=3D"">On Fri, 28 Feb 2014 14:18:50 -0800 Ning Qu &lt;<a href=3D"m=
ailto:quning@google.com">quning@google.com</a>&gt; wrote:<br>
<br>
&gt; This is a follow-up patch for &quot;mm: map few pages around fault add=
ress if they are in page cache&quot;<br>
&gt;<br>
&gt; We use the generic filemap_map_pages as -&gt;map_pages in shmem/tmpfs.=
<br>
&gt;<br>
<br>
</div>Please cc Hugh on shmem/tmpfs things<br>
<div class=3D""><br>
&gt;<br>
&gt; =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
<br>
&gt; Below is just some simple experiment numbers from this patch, let me k=
now if<br>
&gt; you would like more:<br>
&gt;<br>
&gt; Tested on Xeon machine with 64GiB of RAM, using the current default fa=
ult<br>
&gt; order 4.<br>
&gt;<br>
&gt; Sequential access 8GiB file<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 Baseline =C2=A0 =C2=A0 =C2=A0 =C2=A0with-patch<br>
&gt; 1 thread<br>
&gt; =C2=A0 =C2=A0 minor fault =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 205 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 101<br>
<br>
</div>Confused. =C2=A0Sequential access of an 8G file should generate 2,000=
,000<br>
minor faults, not 205. =C2=A0And with FAULT_AROUND_ORDER=3D4, that should c=
ome<br>
down to 2,000,000/16 minor faults when using faultaround?<br>
<div class=3D"HOEnZb"><div class=3D"h5"><br>
&gt; =C2=A0 =C2=A0 time, seconds =C2=A0 =C2=A0 7.94 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A07.82<br>
&gt;<br>
&gt; Random access 8GiB file<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 Baseline =C2=A0 =C2=A0 =C2=A0 =C2=A0with-patch<br>
&gt; 1 thread<br>
&gt; =C2=A0 =C2=A0 minor fault =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 724 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 623<br>
&gt; =C2=A0 =C2=A0 time, seconds =C2=A0 =C2=A0 9.75 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A09.84<br>
&gt;<br>
<br>
</div></div></blockquote></div><br></div>

--001a1136516c7ca5f304f37f1029--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
