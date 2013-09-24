Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id 0B8996B0031
	for <linux-mm@kvack.org>; Tue, 24 Sep 2013 19:48:26 -0400 (EDT)
Received: by mail-pb0-f47.google.com with SMTP id rr4so5236783pbb.34
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 16:48:26 -0700 (PDT)
Received: by mail-vb0-f41.google.com with SMTP id g17so4004750vbg.0
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 16:48:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130924163740.4bc7db61e3e520798220dc4c@linux-foundation.org>
References: <1379937950-8411-1-git-send-email-kirill.shutemov@linux.intel.com> <20130924163740.4bc7db61e3e520798220dc4c@linux-foundation.org>
From: Ning Qu <quning@google.com>
Date: Tue, 24 Sep 2013 16:48:03 -0700
Message-ID: <CACz4_2dEoG22BwU4WuWzXX6cLXDVa6q1B-r=hrkKVN0eX82isw@mail.gmail.com>
Subject: Re: [PATCHv6 00/22] Transparent huge page cache: phase 1, everything
 but mmap()
Content-Type: multipart/alternative; boundary=20cf307cfd68ba009704e729c5f7
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

--20cf307cfd68ba009704e729c5f7
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

I am working on the tmpfs side on top of this patchset, which I assume has
better applications usage than ramfs.

However, I am working on 3.3 so far and will probably get my patches ported
to upstream pretty soon. I believe my patchset is also in early stage but
it does help to get some solid numbers in our own projects, which is very
convincing. However, I think it does depend on the characteristic of the
job .....



Best wishes,
--=20
Ning Qu (=E6=9B=B2=E5=AE=81) | Software Engineer | quning@google.com | +1-4=
08-418-6066


On Tue, Sep 24, 2013 at 4:37 PM, Andrew Morton <akpm@linux-foundation.org>w=
rote:

> On Mon, 23 Sep 2013 15:05:28 +0300 "Kirill A. Shutemov" <
> kirill.shutemov@linux.intel.com> wrote:
>
> > It brings thp support for ramfs, but without mmap() -- it will be poste=
d
> > separately.
>
> We were never going to do this :(
>
> Has anyone reviewed these patches much yet?
>
> > Please review and consider applying.
>
> It appears rather too immature at this stage.
>
> > Intro
> > -----
> >
> > The goal of the project is preparing kernel infrastructure to handle hu=
ge
> > pages in page cache.
> >
> > To proof that the proposed changes are functional we enable the feature
> > for the most simple file system -- ramfs. ramfs is not that useful by
> > itself, but it's good pilot project.
>
> At the very least we should get this done for a real filesystem to see
> how intrusive the changes are and to evaluate the performance changes.
>
>
> Sigh.  A pox on whoever thought up huge pages.  Words cannot express
> how much of a godawful mess they have made of Linux MM.  And it hasn't
> ended yet :( My take is that we'd need to see some very attractive and
> convincing real-world performance numbers before even thinking of
> taking this on.
>
>
>
>

--20cf307cfd68ba009704e729c5f7
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">I am working on the tmpfs side on top of this patchset, wh=
ich I assume has better applications usage than ramfs.<div><br></div><div>H=
owever, I am working on 3.3 so far and will probably get my patches ported =
to upstream pretty soon. I believe my patchset is also in early stage but i=
t does help to get some solid numbers in our own projects, which is very co=
nvincing. However, I think it does depend on the characteristic of the job =
.....</div>

<div><br></div><div><br></div></div><div class=3D"gmail_extra"><br clear=3D=
"all"><div><div><div>Best wishes,<br></div><div><span style=3D"border-colla=
pse:collapse;font-family:arial,sans-serif;font-size:13px">--=C2=A0<br><span=
 style=3D"border-collapse:collapse;font-family:sans-serif;line-height:19px"=
><span style=3D"border-top-width:2px;border-right-width:0px;border-bottom-w=
idth:0px;border-left-width:0px;border-top-style:solid;border-right-style:so=
lid;border-bottom-style:solid;border-left-style:solid;border-top-color:rgb(=
213,15,37);border-right-color:rgb(213,15,37);border-bottom-color:rgb(213,15=
,37);border-left-color:rgb(213,15,37);padding-top:2px;margin-top:2px">Ning =
Qu (=E6=9B=B2=E5=AE=81)<font color=3D"#555555">=C2=A0|</font></span><span s=
tyle=3D"color:rgb(85,85,85);border-top-width:2px;border-right-width:0px;bor=
der-bottom-width:0px;border-left-width:0px;border-top-style:solid;border-ri=
ght-style:solid;border-bottom-style:solid;border-left-style:solid;border-to=
p-color:rgb(51,105,232);border-right-color:rgb(51,105,232);border-bottom-co=
lor:rgb(51,105,232);border-left-color:rgb(51,105,232);padding-top:2px;margi=
n-top:2px">=C2=A0Software Engineer |</span><span style=3D"color:rgb(85,85,8=
5);border-top-width:2px;border-right-width:0px;border-bottom-width:0px;bord=
er-left-width:0px;border-top-style:solid;border-right-style:solid;border-bo=
ttom-style:solid;border-left-style:solid;border-top-color:rgb(0,153,57);bor=
der-right-color:rgb(0,153,57);border-bottom-color:rgb(0,153,57);border-left=
-color:rgb(0,153,57);padding-top:2px;margin-top:2px">=C2=A0<a href=3D"mailt=
o:quning@google.com" style=3D"color:rgb(0,0,204)" target=3D"_blank">quning@=
google.com</a>=C2=A0|</span><span style=3D"color:rgb(85,85,85);border-top-w=
idth:2px;border-right-width:0px;border-bottom-width:0px;border-left-width:0=
px;border-top-style:solid;border-right-style:solid;border-bottom-style:soli=
d;border-left-style:solid;border-top-color:rgb(238,178,17);border-right-col=
or:rgb(238,178,17);border-bottom-color:rgb(238,178,17);border-left-color:rg=
b(238,178,17);padding-top:2px;margin-top:2px">=C2=A0<a value=3D"+1650214387=
7" style=3D"color:rgb(0,0,204)">+1-408-418-6066</a></span></span></span></d=
iv>

</div></div>
<br><br><div class=3D"gmail_quote">On Tue, Sep 24, 2013 at 4:37 PM, Andrew =
Morton <span dir=3D"ltr">&lt;<a href=3D"mailto:akpm@linux-foundation.org" t=
arget=3D"_blank">akpm@linux-foundation.org</a>&gt;</span> wrote:<br><blockq=
uote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc =
solid;padding-left:1ex">

<div class=3D"im">On Mon, 23 Sep 2013 15:05:28 +0300 &quot;Kirill A. Shutem=
ov&quot; &lt;<a href=3D"mailto:kirill.shutemov@linux.intel.com">kirill.shut=
emov@linux.intel.com</a>&gt; wrote:<br>
<br>
&gt; It brings thp support for ramfs, but without mmap() -- it will be post=
ed<br>
&gt; separately.<br>
<br>
</div>We were never going to do this :(<br>
<br>
Has anyone reviewed these patches much yet?<br>
<div class=3D"im"><br>
&gt; Please review and consider applying.<br>
<br>
</div>It appears rather too immature at this stage.<br>
<div class=3D"im"><br>
&gt; Intro<br>
&gt; -----<br>
&gt;<br>
&gt; The goal of the project is preparing kernel infrastructure to handle h=
uge<br>
&gt; pages in page cache.<br>
&gt;<br>
&gt; To proof that the proposed changes are functional we enable the featur=
e<br>
&gt; for the most simple file system -- ramfs. ramfs is not that useful by<=
br>
&gt; itself, but it&#39;s good pilot project.<br>
<br>
</div>At the very least we should get this done for a real filesystem to se=
e<br>
how intrusive the changes are and to evaluate the performance changes.<br>
<br>
<br>
Sigh. =C2=A0A pox on whoever thought up huge pages. =C2=A0Words cannot expr=
ess<br>
how much of a godawful mess they have made of Linux MM. =C2=A0And it hasn&#=
39;t<br>
ended yet :( My take is that we&#39;d need to see some very attractive and<=
br>
convincing real-world performance numbers before even thinking of<br>
taking this on.<br>
<br>
<br>
<br>
</blockquote></div><br></div>

--20cf307cfd68ba009704e729c5f7--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
