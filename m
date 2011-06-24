Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 99632900194
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 21:03:50 -0400 (EDT)
Received: from kpbe20.cbf.corp.google.com (kpbe20.cbf.corp.google.com [172.25.105.84])
	by smtp-out.google.com with ESMTP id p5O13jlH021461
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 18:03:45 -0700
Received: from gyh4 (gyh4.prod.google.com [10.243.50.196])
	by kpbe20.cbf.corp.google.com with ESMTP id p5O12x3m020432
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 18:03:44 -0700
Received: by gyh4 with SMTP id 4so1131033gyh.36
        for <linux-mm@kvack.org>; Thu, 23 Jun 2011 18:03:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <987664A83D2D224EAE907B061CE93D5301E938F2FD@orsmsx505.amr.corp.intel.com>
References: <1308741534-6846-1-git-send-email-sassmann@kpanic.de>
	<20110623133950.GB28333@srcf.ucam.org>
	<4E0348E0.7050808@kpanic.de>
	<20110623141222.GA30003@srcf.ucam.org>
	<4E035DD1.1030603@kpanic.de>
	<20110623170014.GN3263@one.firstfloor.org>
	<987664A83D2D224EAE907B061CE93D5301E938F2FD@orsmsx505.amr.corp.intel.com>
Date: Thu, 23 Jun 2011 18:03:42 -0700
Message-ID: <BANLkTikTTCU3eKkCtrbLbtpLJtksehyEMg@mail.gmail.com>
Subject: Re: [PATCH v2 0/3] support for broken memory modules (BadRAM)
From: Craig Bergstrom <craigb@google.com>
Content-Type: multipart/alternative; boundary=001485f9a4f0d3830504a66ac544
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, Stefan Assmann <sassmann@kpanic.de>, Matthew Garrett <mjg59@srcf.ucam.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mingo@elte.hu" <mingo@elte.hu>, "hpa@zytor.com" <hpa@zytor.com>, "rick@vanrein.org" <rick@vanrein.org>, "rdunlap@xenotime.net" <rdunlap@xenotime.net>

--001485f9a4f0d3830504a66ac544
Content-Type: text/plain; charset=ISO-8859-1

On Thu, Jun 23, 2011 at 10:12 AM, Luck, Tony <tony.luck@intel.com> wrote:

> > I don't think it makes sense to handle something like that with a list.
> > The compact representation currently in badram is great for that.
>
> I'd tend to agree here.  Rick has made a convincing argument that there
> are significant numbers of real world cases where a defective row/column
> in a DIMM results in a predictable pattern of errors.  The ball is now
> in Google's court to take a look at their systems that have high numbers
> of errors to see if they can actually be described by a small number
> of BadRAM patterns as Rick has claimed.
>
>
Hi All,

We (Google) are working on a data-driven answer for this question.  I know
that there has been some analysis on this topic on the past, but I don't
want to speculate until we've had some time to put all the pieces together.
 Stay tuned for specifics.

Cheers,
CraigB



> -Tony
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>

--001485f9a4f0d3830504a66ac544
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Thu, Jun 23, 2011 at 10:12 AM, Luck, =
Tony <span dir=3D"ltr">&lt;<a href=3D"mailto:tony.luck@intel.com">tony.luck=
@intel.com</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" style=
=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<div class=3D"im">&gt; I don&#39;t think it makes sense to handle something=
 like that with a list.<br>
&gt; The compact representation currently in badram is great for that.<br>
<br>
</div>I&#39;d tend to agree here. =A0Rick has made a convincing argument th=
at there<br>
are significant numbers of real world cases where a defective row/column<br=
>
in a DIMM results in a predictable pattern of errors. =A0The ball is now<br=
>
in Google&#39;s court to take a look at their systems that have high number=
s<br>
of errors to see if they can actually be described by a small number<br>
of BadRAM patterns as Rick has claimed.<br>
<font color=3D"#888888"><br></font></blockquote><div><br></div><div>Hi All,=
</div><div><br></div><div>We (Google) are working on a data-driven answer f=
or this question. =A0I know that there has been some analysis on this topic=
 on the past, but I don&#39;t want to speculate until we&#39;ve had some ti=
me to put all the pieces together. =A0Stay tuned for specifics.</div>
<div><br></div><div>Cheers,</div><div>CraigB</div><div><br></div><div>=A0</=
div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-lef=
t:1px #ccc solid;padding-left:1ex;"><font color=3D"#888888">
-Tony<br>
</font><div><div></div><div class=3D"h5">--<br>
To unsubscribe from this list: send the line &quot;unsubscribe linux-kernel=
&quot; in<br>
the body of a message to <a href=3D"mailto:majordomo@vger.kernel.org">major=
domo@vger.kernel.org</a><br>
More majordomo info at =A0<a href=3D"http://vger.kernel.org/majordomo-info.=
html" target=3D"_blank">http://vger.kernel.org/majordomo-info.html</a><br>
Please read the FAQ at =A0<a href=3D"http://www.tux.org/lkml/" target=3D"_b=
lank">http://www.tux.org/lkml/</a><br>
</div></div></blockquote></div><br>

--001485f9a4f0d3830504a66ac544--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
