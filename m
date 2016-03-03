Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f47.google.com (mail-vk0-f47.google.com [209.85.213.47])
	by kanga.kvack.org (Postfix) with ESMTP id E150D6B0254
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 04:27:43 -0500 (EST)
Received: by mail-vk0-f47.google.com with SMTP id c3so15506984vkb.3
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 01:27:43 -0800 (PST)
Received: from mail-vk0-x22e.google.com (mail-vk0-x22e.google.com. [2607:f8b0:400c:c05::22e])
        by mx.google.com with ESMTPS id e21si24914081vkd.21.2016.03.03.01.27.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Mar 2016 01:27:42 -0800 (PST)
Received: by mail-vk0-x22e.google.com with SMTP id c3so15506729vkb.3
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 01:27:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160303082254.GA26202@dhcp22.suse.cz>
References: <CAKQB+ft3q2O2xYG2CTmTM9OCRLCP2FPTfHQ3jvcFSM-FGrjgGA@mail.gmail.com>
	<20160302173639.GD26701@dhcp22.suse.cz>
	<CAKQB+fss2UZOP-39GCpQY3T8MJoErm_0AeDnnAPZZ4MEWLXs7g@mail.gmail.com>
	<20160303082254.GA26202@dhcp22.suse.cz>
Date: Thu, 3 Mar 2016 17:27:42 +0800
Message-ID: <CAKQB+fs31HCrXqNXz3+Cr1djwiqokdMLNOZbppCB8T2bJB1Pbw@mail.gmail.com>
Subject: Re: kswapd consumes 100% CPU when highest zone is small
From: Jerry Lee <leisurelysw24@gmail.com>
Content-Type: multipart/alternative; boundary=001a114406ea480457052d219c4f
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org

--001a114406ea480457052d219c4f
Content-Type: text/plain; charset=UTF-8

On 3 March 2016 at 16:22, Michal Hocko <mhocko@kernel.org> wrote:

> On Thu 03-03-16 10:23:03, Jerry Lee wrote:
> > On 3 March 2016 at 01:36, Michal Hocko <mhocko@kernel.org> wrote:
> >
> > > On Wed 02-03-16 14:20:38, Jerry Lee wrote:
> [...]
> > > > Is there anything I could do to totally get rid of the problem?
> > >
> > > I would try to sacrifice those few megs and get rid of zone normal
> > > completely. AFAIR mem=4G should limit the max_pfn to 4G so DMA32 should
> > > cover the shole memory.
> > >
> >
> > I came up with a patch that seem to work well on my system.  But, I
> > am afraid that it breaks the rule that all zones must be balanced for
> > order-0 request and It may cause some other side-effect?  I thought
> > that the patch is just a workaround (a bad one) and not a cure-all.
>
> One thing I haven't noticed previously is that you are running on the 3.12
> kernel. I vaguely remember there were some fixes for small zones. Not
> sure it would work for such a small zone but it would be worth trying I
> guess. Could you retest with 4.4?
>

Hi,

Thanks for the quick feedback!

Before sending a mail to linux-mm, I found that there were discussions and
fixes for the small zone as you remember:
https://lkml.org/lkml/2011/6/24/161 .
However, the fixes is kind of old and should be already included into the
current kernel version.  Speaking of retesting the issue with kernel-4.4,
it's
a bit hard for my right now because there are some customized hardware and
drivers on my system but I could give it a try.

BTW, there are some information I forgot to mention before.  Originally, I
use
kernel-3.4 on my system without the kswapd issue.  After upgrading to
linux-3.12.x, the issue occur.  In addition, I found that there are other
people
encountering the same problem even linux-4.x are used. [1] The idea to
increase the value of min_free_kbytes comes from the post. [1]

[1] https://github.com/GalliumOS/galliumos-distro/issues/52

Anyway, thanks again for your help and suggestion!

- Jerry



> --
> Michal Hocko
> SUSE Labs
>

--001a114406ea480457052d219c4f
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_extra"><br><div class=3D"gmail_quote">=
On 3 March 2016 at 16:22, Michal Hocko <span dir=3D"ltr">&lt;<a href=3D"mai=
lto:mhocko@kernel.org" target=3D"_blank">mhocko@kernel.org</a>&gt;</span> w=
rote:<br><blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8e=
x;border-left:1px solid rgb(204,204,204);padding-left:1ex"><span class=3D""=
>On Thu 03-03-16 10:23:03, Jerry Lee wrote:<br>
&gt; On 3 March 2016 at 01:36, Michal Hocko &lt;<a href=3D"mailto:mhocko@ke=
rnel.org">mhocko@kernel.org</a>&gt; wrote:<br>
&gt;<br>
&gt; &gt; On Wed 02-03-16 14:20:38, Jerry Lee wrote:<br>
</span>[...]<br>
<span class=3D"">&gt; &gt; &gt; Is there anything I could do to totally get=
 rid of the problem?<br>
&gt; &gt;<br>
&gt; &gt; I would try to sacrifice those few megs and get rid of zone norma=
l<br>
&gt; &gt; completely. AFAIR mem=3D4G should limit the max_pfn to 4G so DMA3=
2 should<br>
&gt; &gt; cover the shole memory.<br>
&gt; &gt;<br>
&gt;<br>
&gt; I came up with a patch that seem to work well on my system.=C2=A0 But,=
 I<br>
&gt; am afraid that it breaks the rule that all zones must be balanced for<=
br>
&gt; order-0 request and It may cause some other side-effect?=C2=A0 I thoug=
ht<br>
&gt; that the patch is just a workaround (a bad one) and not a cure-all.<br=
>
<br>
</span>One thing I haven&#39;t noticed previously is that you are running o=
n the 3.12<br>
kernel. I vaguely remember there were some fixes for small zones. Not<br>
sure it would work for such a small zone but it would be worth trying I<br>
guess. Could you retest with 4.4?<br></blockquote><div><br></div><div>Hi,<b=
r><br></div><div>Thanks for the quick feedback!<br></div><div><br></div><di=
v>Before sending a mail to linux-mm, I found that there were discussions an=
d <br>fixes for the small zone as you remember: <a href=3D"https://lkml.org=
/lkml/2011/6/24/161">https://lkml.org/lkml/2011/6/24/161</a> .<br></div><di=
v>However, the fixes is kind of old and should be already included into the=
 <br></div><div>current kernel version.=C2=A0 Speaking of retesting the iss=
ue with kernel-4.4, it&#39;s <br></div><div>a bit hard for my right now bec=
ause there are some customized hardware and <br></div><div>drivers on my sy=
stem but I could give it a try.<br><br></div><div>BTW, there are some infor=
mation I forgot to mention before.=C2=A0 Originally, I use <br>kernel-3.4 o=
n my system without the kswapd issue.=C2=A0 After upgrading to <br></div><d=
iv>linux-3.12.x, the issue occur.=C2=A0 In addition, I found that there are=
 other people<br></div><div>encountering the same problem even linux-4.x ar=
e used. [1] The idea to <br></div><div>increase the value of min_free_kbyte=
s comes from the post. [1] </div><div><br></div><div>[1] <a href=3D"https:/=
/github.com/GalliumOS/galliumos-distro/issues/52">https://github.com/Galliu=
mOS/galliumos-distro/issues/52</a><br></div><div><br></div><div>Anyway, tha=
nks again for your help and suggestion!<br><br></div><div>- Jerry<br></div>=
<div><br>=C2=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0px =
0px 0px 0.8ex;border-left:1px solid rgb(204,204,204);padding-left:1ex">
<div class=3D""><div class=3D"h5">--<br>
Michal Hocko<br>
SUSE Labs<br>
</div></div></blockquote></div><br></div></div>

--001a114406ea480457052d219c4f--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
