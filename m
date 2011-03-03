Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 91F8A8D0039
	for <linux-mm@kvack.org>; Wed,  2 Mar 2011 22:11:04 -0500 (EST)
Received: by iyf13 with SMTP id 13so712320iyf.14
        for <linux-mm@kvack.org>; Wed, 02 Mar 2011 19:11:02 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110302082412.87f153ba.rdunlap@xenotime.net>
References: <1299055090-23976-1-git-send-email-namei.unix@gmail.com>
	<20110302082412.87f153ba.rdunlap@xenotime.net>
Date: Thu, 3 Mar 2011 11:11:02 +0800
Message-ID: <AANLkTikp+BpM7CsOD5o+XFJqicm0UN_RST5xrVQC2mTy@mail.gmail.com>
Subject: Re: [RFC PATCH 1/5] x86/Kconfig: Add Page Cache Accounting entry
From: Liu Yuan <namei.unix@gmail.com>
Content-Type: multipart/alternative; boundary=20cf305644751d1c2f049d8b61fe
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@xenotime.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jaxboe@fusionio.com, akpm@linux-foundation.org, fengguang.wu@intel.com

--20cf305644751d1c2f049d8b61fe
Content-Type: text/plain; charset=ISO-8859-1

On Thu, Mar 3, 2011 at 12:24 AM, Randy Dunlap <rdunlap@xenotime.net> wrote:

> On Wed,  2 Mar 2011 16:38:06 +0800 Liu Yuan wrote:
>
> > From: Liu Yuan <tailai.ly@taobao.com>
> >
> > Signed-off-by: Liu Yuan <tailai.ly@taobao.com>
> > ---
> >  arch/x86/Kconfig.debug |    9 +++++++++
> >  1 files changed, 9 insertions(+), 0 deletions(-)
> >
> > diff --git a/arch/x86/Kconfig.debug b/arch/x86/Kconfig.debug
> > index 615e188..f29e32d 100644
> > --- a/arch/x86/Kconfig.debug
> > +++ b/arch/x86/Kconfig.debug
> > @@ -304,4 +304,13 @@ config DEBUG_STRICT_USER_COPY_CHECKS
> >
> >         If unsure, or if you run an older (pre 4.4) gcc, say N.
> >
> > +config PAGE_CACHE_ACCT
> > +     bool "Page cache accounting"
> > +     ---help---
> > +       Enabling this options to account for page cache hit/missed number
> of
> > +       times. This would allow user space applications get better
> knowledge
> > +       of underlying page cache system by reading virtual file. The
> statitics
> > +       per partition are collected.
> > +
> > +       If unsure, say N.
> >  endmenu
> > --
>
> rewrite:
>
>          Enable this option to provide for page cache hit/miss counters.
>          This allows userspace applications to obtain better knowledge of
> the
>          underlying page cache subsystem by reading a virtual file.
>          Statistics are collect per partition.
>
> questions:
>        what virtual file?
>        what kind of partition?
>
>
Hi Randy,

Thanks for your correction.

'virtual file' in this patch context means files in sysfs mounted at /sys.
'partition' indicates that every disk partition (like
/dev/sda/{sda1,sda2...} has its own accountings for page cache information.

I am not confident about phrasing. so please correct it if you think it is
way better.

Thanks,
Liu Yuan

--20cf305644751d1c2f049d8b61fe
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Thu, Mar 3, 2011 at 12:24 AM, Randy D=
unlap <span dir=3D"ltr">&lt;<a href=3D"mailto:rdunlap@xenotime.net">rdunlap=
@xenotime.net</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" st=
yle=3D"margin: 0pt 0pt 0pt 0.8ex; border-left: 1px solid rgb(204, 204, 204)=
; padding-left: 1ex;">
<div><div></div><div class=3D"h5">On Wed, =A02 Mar 2011 16:38:06 +0800 Liu =
Yuan wrote:<br>
<br>
&gt; From: Liu Yuan &lt;<a href=3D"http://tailai.ly" target=3D"_blank">tail=
ai.ly</a>@<a href=3D"http://taobao.com" target=3D"_blank">taobao.com</a>&gt=
;<br>
&gt;<br>
&gt; Signed-off-by: Liu Yuan &lt;<a href=3D"http://tailai.ly" target=3D"_bl=
ank">tailai.ly</a>@<a href=3D"http://taobao.com" target=3D"_blank">taobao.c=
om</a>&gt;<br>
&gt; ---<br>
&gt; =A0arch/x86/Kconfig.debug | =A0 =A09 +++++++++<br>
&gt; =A01 files changed, 9 insertions(+), 0 deletions(-)<br>
&gt;<br>
&gt; diff --git a/arch/x86/Kconfig.debug b/arch/x86/Kconfig.debug<br>
&gt; index 615e188..f29e32d 100644<br>
&gt; --- a/arch/x86/Kconfig.debug<br>
&gt; +++ b/arch/x86/Kconfig.debug<br>
&gt; @@ -304,4 +304,13 @@ config DEBUG_STRICT_USER_COPY_CHECKS<br>
&gt;<br>
&gt; =A0 =A0 =A0 =A0 If unsure, or if you run an older (pre 4.4) gcc, say N=
.<br>
&gt;<br>
&gt; +config PAGE_CACHE_ACCT<br>
&gt; + =A0 =A0 bool &quot;Page cache accounting&quot;<br>
&gt; + =A0 =A0 ---help---<br>
&gt; + =A0 =A0 =A0 Enabling this options to account for page cache hit/miss=
ed number of<br>
&gt; + =A0 =A0 =A0 times. This would allow user space applications get bett=
er knowledge<br>
&gt; + =A0 =A0 =A0 of underlying page cache system by reading virtual file.=
 The statitics<br>
&gt; + =A0 =A0 =A0 per partition are collected.<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 If unsure, say N.<br>
&gt; =A0endmenu<br>
&gt; --<br>
<br>
</div></div>rewrite:<br>
<br>
 =A0 =A0 =A0 =A0 =A0Enable this option to provide for page cache hit/miss c=
ounters.<br>
 =A0 =A0 =A0 =A0 =A0This allows userspace applications to obtain better kno=
wledge of the<br>
 =A0 =A0 =A0 =A0 =A0underlying page cache subsystem by reading a virtual fi=
le.<br>
 =A0 =A0 =A0 =A0 =A0Statistics are collect per partition.<br>
<br>
questions:<br>
 =A0 =A0 =A0 =A0what virtual file?<br>
 =A0 =A0 =A0 =A0what kind of partition?<br><br></blockquote><div><br>Hi Ran=
dy,<br><br>Thanks for your correction. <br><br>&#39;virtual file&#39; in th=
is patch context means files in sysfs mounted at /sys.<br>&#39;partition&#3=
9;
 indicates that every disk partition (like /dev/sda/{sda1,sda2...} has=20
its own accountings for page cache information.<br>
<br>I am not confident about phrasing. so please correct it if you think it=
 is way better.<br><br>Thanks,<br>Liu Yuan <br></div></div>

--20cf305644751d1c2f049d8b61fe--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
