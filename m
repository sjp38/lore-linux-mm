Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 048176B004A
	for <linux-mm@kvack.org>; Mon, 12 Mar 2012 13:32:54 -0400 (EDT)
Received: by yenm8 with SMTP id m8so3600724yen.14
        for <linux-mm@kvack.org>; Mon, 12 Mar 2012 10:32:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1203121102590.6396@router.home>
References: <CAFLer81iFkuyQQc8M_AR9pULQDyrMYZux2s3KPK-3kGzB2XTKw@mail.gmail.com>
	<alpine.DEB.2.00.1203121102590.6396@router.home>
Date: Mon, 12 Mar 2012 13:32:51 -0400
Message-ID: <CAFLer82Nt7gZm-Sq_F_2q0PYp1bUht0op=PvfMu5BW8YwbBMHw@mail.gmail.com>
Subject: Re: ClockPro in Linux MM
From: Zheng Da <zhengda1936@gmail.com>
Content-Type: multipart/alternative; boundary=20cf303f6a44bcdaf604bb0f217a
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org

--20cf303f6a44bcdaf604bb0f217a
Content-Type: text/plain; charset=ISO-8859-1

I know the implementation is different. Linux implementation doesn't have
the clock heads.
But I get a feel that the essence is the same except that Linux version
doesn't have non-resident pages.

Da

On Mon, Mar 12, 2012 at 12:04 PM, Christoph Lameter <cl@linux.com> wrote:

> On Mon, 12 Mar 2012, Zheng Da wrote:
>
> > I try to understand the Linux memory management. I was told Linux uses
> > ClockPro to manage page cache
> > and http://linux-mm.org/PageReplacementDesign also says so for file
> pages.
> > But when I read the ClockPro paper,
> > it doesn't look the same. The Linux implementation doesn't have
> > non-resident pages. Other than
> > that, it doesn't have the same test period mentioned in the paper. I
> wonder
> > if the Linux implementation
> > have the same effect as ClockPro. Could anyone confirm Linux is still
> using
> > ClockPro?
>
> That Linux is using Clockpro is news to me. Linux Memory management uses
> some ideas from Clockpro to improve reclaim etc but it does not implement
> ClockPro.
>
>

--20cf303f6a44bcdaf604bb0f217a
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

I know the implementation is different. Linux implementation doesn&#39;t ha=
ve the clock heads.<div>But I get a feel that the essence is the same excep=
t that Linux version doesn&#39;t have non-resident pages.</div><div><br>
</div><div>Da<br><br><div class=3D"gmail_quote">On Mon, Mar 12, 2012 at 12:=
04 PM, Christoph Lameter <span dir=3D"ltr">&lt;<a href=3D"mailto:cl@linux.c=
om">cl@linux.com</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote"=
 style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
<div class=3D"HOEnZb"><div class=3D"h5">On Mon, 12 Mar 2012, Zheng Da wrote=
:<br>
<br>
&gt; I try to understand the Linux memory management. I was told Linux uses=
<br>
&gt; ClockPro to manage page cache<br>
&gt; and <a href=3D"http://linux-mm.org/PageReplacementDesign" target=3D"_b=
lank">http://linux-mm.org/PageReplacementDesign</a> also says so for file p=
ages.<br>
&gt; But when I read the ClockPro paper,<br>
&gt; it doesn&#39;t look the same. The Linux implementation doesn&#39;t hav=
e<br>
&gt; non-resident pages. Other than<br>
&gt; that, it doesn&#39;t have the same test period mentioned in the paper.=
 I wonder<br>
&gt; if the Linux implementation<br>
&gt; have the same effect as ClockPro. Could anyone confirm Linux is still =
using<br>
&gt; ClockPro?<br>
<br>
</div></div>That Linux is using Clockpro is news to me. Linux Memory manage=
ment uses<br>
some ideas from Clockpro to improve reclaim etc but it does not implement C=
lockPro.<br>
<br>
</blockquote></div><br></div>

--20cf303f6a44bcdaf604bb0f217a--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
