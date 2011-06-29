Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id CF3146B00E8
	for <linux-mm@kvack.org>; Wed, 29 Jun 2011 11:28:30 -0400 (EDT)
Received: by vxg38 with SMTP id 38so1398824vxg.14
        for <linux-mm@kvack.org>; Wed, 29 Jun 2011 08:28:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110629080827.GA975@phantom.vanrein.org>
References: <fa.fHPNPTsllvyE/7DxrKwiwgVbVww@ifi.uio.no>
	<532cc290-4b9c-4eb2-91d4-aa66c01bb3a0@glegroupsg2000goo.googlegroups.com>
	<BANLkTik3mEJGXLrf_XtssfdRypm3NxBKvkhcnUpK=YXV6ux=Ag@mail.gmail.com>
	<20110629080827.GA975@phantom.vanrein.org>
Date: Wed, 29 Jun 2011 08:28:26 -0700
Message-ID: <BANLkTikw9bnrurUo8n-6yUwwQ0zOv5iAOBDt=T6Nm6nkUd7vLA@mail.gmail.com>
Subject: Re: [PATCH v2 0/3] support for broken memory modules (BadRAM)
From: craig lkml <craig.lkml@gmail.com>
Content-Type: multipart/alternative; boundary=bcaec501665b9626c704a6db6f94
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rick van Rein <rick@vanrein.org>
Cc: Craig Bergstrom <craigb@google.com>, fa.linux.kernel@googlegroups.com, "H. Peter Anvin" <hpa@zytor.com>, Stefan Assmann <sassmann@kpanic.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "Luck, Tony" <tony.luck@intel.com>, Andi Kleen <andi@firstfloor.org>, "mingo@elte.hu" <mingo@elte.hu>, "rdunlap@xenotime.net" <rdunlap@xenotime.net>, Nancy Yuen <yuenn@google.com>, Michael Ditto <mditto@google.com>

--bcaec501665b9626c704a6db6f94
Content-Type: text/plain; charset=ISO-8859-1

Hi Rick,

Thanks for your response.  My sincere apologies for not posting the work
directly.

My intention is to point interested parties to contributions that Google has
made to this space through known and respected channels.  The cited research
is not my research but the research of my colleagues.  As a result, I
hesitate to paraphrase the work as I will likely get the details wrong.  In
any case, Shane's points are the most relevant for the discussion here.
 Please refer to his post in this thread.

In an attempt to contribute to the community as much as I can, I have
prepared and mailed our BadRAM patch as requested.  In case it is not
otherwise clear, my belief is that the ideal solution for the upstream
kernel is a hybrid of our approaches.

Thank you,
CraigB

On Wed, Jun 29, 2011 at 1:08 AM, Rick van Rein <rick@vanrein.org> wrote:

> Hello Craig,
>
> > Some folks had mentioned that they're interested in details about what
> > we've learned about bad ram from our fleet of machines.  I suspect
> > that you need ACM portal access to read this,
>
> I'm happy that this didn't cause a flame, but clearly this is not the
> right response in an open environment.  ACM may have copyright on the
> *form* in which you present your knowledge, but could you please poor
> the knowledge in another form that bypasses their copyright so the
> knowledge is made available to all?
>
>
> Thanks,
>  -Rick
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>

--bcaec501665b9626c704a6db6f94
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Hi Rick,<div><br></div><div>Thanks for your response. =A0My sincere apologi=
es for not posting the work directly.</div><div><br></div><div>My intention=
 is to point interested parties to contributions that Google has made to th=
is space through known and respected channels. =A0The cited research is not=
 my research but the research of my=A0colleagues. =A0As a result, I hesitat=
e to paraphrase the work as I will likely get the details wrong. =A0In any =
case, Shane&#39;s points are the most relevant for the discussion here. =A0=
Please refer to his post in this thread.</div>
<div><br></div><div>In an attempt to contribute to the community as much as=
 I can, I have prepared and mailed our BadRAM patch as requested. =A0In cas=
e it is not otherwise clear, my belief is that the ideal solution for the u=
pstream kernel is a hybrid of our approaches.</div>
<div><br></div><div>Thank you,</div><div>CraigB<br><br><div class=3D"gmail_=
quote">On Wed, Jun 29, 2011 at 1:08 AM, Rick van Rein <span dir=3D"ltr">&lt=
;<a href=3D"mailto:rick@vanrein.org">rick@vanrein.org</a>&gt;</span> wrote:=
<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex;">Hello Craig,<br>
<div class=3D"im"><br>
&gt; Some folks had mentioned that they&#39;re interested in details about =
what<br>
&gt; we&#39;ve learned about bad ram from our fleet of machines. =A0I suspe=
ct<br>
&gt; that you need ACM portal access to read this,<br>
<br>
</div>I&#39;m happy that this didn&#39;t cause a flame, but clearly this is=
 not the<br>
right response in an open environment. =A0ACM may have copyright on the<br>
*form* in which you present your knowledge, but could you please poor<br>
the knowledge in another form that bypasses their copyright so the<br>
knowledge is made available to all?<br>
<br>
<br>
Thanks,<br>
<div class=3D"im">=A0-Rick<br>
--<br>
To unsubscribe from this list: send the line &quot;unsubscribe linux-kernel=
&quot; in<br>
</div><div><div></div><div class=3D"h5">the body of a message to <a href=3D=
"mailto:majordomo@vger.kernel.org">majordomo@vger.kernel.org</a><br>
More majordomo info at =A0<a href=3D"http://vger.kernel.org/majordomo-info.=
html" target=3D"_blank">http://vger.kernel.org/majordomo-info.html</a><br>
Please read the FAQ at =A0<a href=3D"http://www.tux.org/lkml/" target=3D"_b=
lank">http://www.tux.org/lkml/</a><br>
</div></div></blockquote></div><br></div>

--bcaec501665b9626c704a6db6f94--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
