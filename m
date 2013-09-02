Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 246C16B0032
	for <linux-mm@kvack.org>; Mon,  2 Sep 2013 16:05:24 -0400 (EDT)
Received: by mail-vc0-f179.google.com with SMTP id ht10so3372118vcb.10
        for <linux-mm@kvack.org>; Mon, 02 Sep 2013 13:05:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130902113616.6C750E0090@blue.fi.intel.com>
References: <1375582645-29274-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1375582645-29274-6-git-send-email-kirill.shutemov@linux.intel.com>
 <CACz4_2eY3cniz6mV-Nwi6jBEEOfETJs1GXrjHBppr=Grjnwiqw@mail.gmail.com> <20130902113616.6C750E0090@blue.fi.intel.com>
From: Ning Qu <quning@google.com>
Date: Mon, 2 Sep 2013 13:05:02 -0700
Message-ID: <CACz4_2dcrwcT3fi4s_4yLEuT2T2NFWMZVcb-KKi1SXA8+aF-dg@mail.gmail.com>
Subject: Re: [PATCH 05/23] thp: represent file thp pages in meminfo and friends
Content-Type: multipart/alternative; boundary=089e0160cc3aa7a86f04e56c17d6
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

--089e0160cc3aa7a86f04e56c17d6
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Oh, I can see it, those patches make their way into Andrew's tree a few
days ago.

It kinda of make it harder for me to maintain the backport from the
patchset.

Btw, I am comparing the different between your most recent patchset vs v4.
Are you planning to release any new patch set?

After consolidating my backport with your most recent patchset, I probably
will see if I can get my patch on tmpfs adapting to 3.11. I will let you
know once I get there.

Thanks!

Best wishes,
--=20
Ning Qu (=E6=9B=B2=E5=AE=81) | Software Engineer | quning@google.com | +1-4=
08-418-6066


On Mon, Sep 2, 2013 at 4:36 AM, Kirill A. Shutemov <
kirill.shutemov@linux.intel.com> wrote:

> Ning Qu wrote:
> > Hi, Kirill
> >
> > I believe there is a typo in your previous commit, but you didn't inclu=
de
> > it in this series of patch set. Below is the link for the commit. I thi=
nk
> > you are trying to decrease the value NR_ANON_PAGES in page_remove_rmap,
> but
> > it is currently adding the value instead when using
> __mod_zone_page_state.Let
> > me know if you would like to fix it in your commit or you want another
> > patch from me. Thanks!
>
> The patch is already in Andrew's tree. I'll send a fix for that. Thanks.
>
> --
>  Kirill A. Shutemov
>

--089e0160cc3aa7a86f04e56c17d6
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Oh, I can see it, those patches make their way into Andrew=
&#39;s tree a few days ago.<div><br></div><div>It kinda of make it harder f=
or me to maintain the backport from the patchset.</div><div><br></div><div>

Btw, I am comparing the different between your most recent patchset vs v4. =
Are you planning to release any new patch set?=C2=A0</div><div><br></div><d=
iv>After consolidating my backport with your most recent patchset, I probab=
ly will see if I can get my patch on tmpfs adapting to 3.11. I will let you=
 know once I get there.</div>

<div><br></div><div>Thanks!</div></div><div class=3D"gmail_extra"><br clear=
=3D"all"><div><div><div>Best wishes,<br></div><div><span style=3D"border-co=
llapse:collapse;font-family:arial,sans-serif;font-size:13px">--=C2=A0<br><s=
pan style=3D"border-collapse:collapse;font-family:sans-serif;line-height:19=
px"><span style=3D"border-top-width:2px;border-right-width:0px;border-botto=
m-width:0px;border-left-width:0px;border-top-style:solid;border-right-style=
:solid;border-bottom-style:solid;border-left-style:solid;border-top-color:r=
gb(213,15,37);border-right-color:rgb(213,15,37);border-bottom-color:rgb(213=
,15,37);border-left-color:rgb(213,15,37);padding-top:2px;margin-top:2px">Ni=
ng Qu (=E6=9B=B2=E5=AE=81)<font color=3D"#555555">=C2=A0|</font></span><spa=
n style=3D"color:rgb(85,85,85);border-top-width:2px;border-right-width:0px;=
border-bottom-width:0px;border-left-width:0px;border-top-style:solid;border=
-right-style:solid;border-bottom-style:solid;border-left-style:solid;border=
-top-color:rgb(51,105,232);border-right-color:rgb(51,105,232);border-bottom=
-color:rgb(51,105,232);border-left-color:rgb(51,105,232);padding-top:2px;ma=
rgin-top:2px">=C2=A0Software Engineer |</span><span style=3D"color:rgb(85,8=
5,85);border-top-width:2px;border-right-width:0px;border-bottom-width:0px;b=
order-left-width:0px;border-top-style:solid;border-right-style:solid;border=
-bottom-style:solid;border-left-style:solid;border-top-color:rgb(0,153,57);=
border-right-color:rgb(0,153,57);border-bottom-color:rgb(0,153,57);border-l=
eft-color:rgb(0,153,57);padding-top:2px;margin-top:2px">=C2=A0<a href=3D"ma=
ilto:quning@google.com" style=3D"color:rgb(0,0,204)" target=3D"_blank">quni=
ng@google.com</a>=C2=A0|</span><span style=3D"color:rgb(85,85,85);border-to=
p-width:2px;border-right-width:0px;border-bottom-width:0px;border-left-widt=
h:0px;border-top-style:solid;border-right-style:solid;border-bottom-style:s=
olid;border-left-style:solid;border-top-color:rgb(238,178,17);border-right-=
color:rgb(238,178,17);border-bottom-color:rgb(238,178,17);border-left-color=
:rgb(238,178,17);padding-top:2px;margin-top:2px">=C2=A0<a value=3D"+1650214=
3877" style=3D"color:rgb(0,0,204)">+1-408-418-6066</a></span></span></span>=
</div>

</div></div>
<br><br><div class=3D"gmail_quote">On Mon, Sep 2, 2013 at 4:36 AM, Kirill A=
. Shutemov <span dir=3D"ltr">&lt;<a href=3D"mailto:kirill.shutemov@linux.in=
tel.com" target=3D"_blank">kirill.shutemov@linux.intel.com</a>&gt;</span> w=
rote:<br>

<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex"><div class=3D"im">Ning Qu wrote:<br>
&gt; Hi, Kirill<br>
&gt;<br>
&gt; I believe there is a typo in your previous commit, but you didn&#39;t =
include<br>
&gt; it in this series of patch set. Below is the link for the commit. I th=
ink<br>
&gt; you are trying to decrease the value NR_ANON_PAGES in page_remove_rmap=
, but<br>
&gt; it is currently adding the value instead when using __mod_zone_page_st=
ate.Let<br>
&gt; me know if you would like to fix it in your commit or you want another=
<br>
&gt; patch from me. Thanks!<br>
<br>
</div>The patch is already in Andrew&#39;s tree. I&#39;ll send a fix for th=
at. Thanks.<br>
<span class=3D"HOEnZb"><font color=3D"#888888"><br>
--<br>
=C2=A0Kirill A. Shutemov<br>
</font></span></blockquote></div><br></div>

--089e0160cc3aa7a86f04e56c17d6--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
