Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id DAF7B900234
	for <linux-mm@kvack.org>; Fri, 24 Jun 2011 10:34:31 -0400 (EDT)
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id p5OEYMKJ011269
	for <linux-mm@kvack.org>; Fri, 24 Jun 2011 07:34:23 -0700
Received: from yia27 (yia27.prod.google.com [10.243.65.27])
	by wpaz33.hot.corp.google.com with ESMTP id p5OEXtGu010473
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 24 Jun 2011 07:34:21 -0700
Received: by yia27 with SMTP id 27so1532587yia.33
        for <linux-mm@kvack.org>; Fri, 24 Jun 2011 07:34:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110624080535.GA19966@phantom.vanrein.org>
References: <1308741534-6846-1-git-send-email-sassmann@kpanic.de>
	<20110623133950.GB28333@srcf.ucam.org>
	<4E0348E0.7050808@kpanic.de>
	<20110623141222.GA30003@srcf.ucam.org>
	<4E035DD1.1030603@kpanic.de>
	<20110623170014.GN3263@one.firstfloor.org>
	<987664A83D2D224EAE907B061CE93D5301E938F2FD@orsmsx505.amr.corp.intel.com>
	<BANLkTikTTCU3eKkCtrbLbtpLJtksehyEMg@mail.gmail.com>
	<20110624080535.GA19966@phantom.vanrein.org>
Date: Fri, 24 Jun 2011 07:34:21 -0700
Message-ID: <BANLkTimRaN0OH3ZaJHGSsT871HDLZaUv08Y-WfR_+T7Rq58g=g@mail.gmail.com>
Subject: Re: [PATCH v2 0/3] support for broken memory modules (BadRAM)
From: Craig Bergstrom <craigb@google.com>
Content-Type: multipart/alternative; boundary=001636b42dc2ee70f904a6761836
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rick van Rein <rick@vanrein.org>
Cc: "Luck, Tony" <tony.luck@intel.com>, Andi Kleen <andi@firstfloor.org>, Stefan Assmann <sassmann@kpanic.de>, Matthew Garrett <mjg59@srcf.ucam.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mingo@elte.hu" <mingo@elte.hu>, "hpa@zytor.com" <hpa@zytor.com>, "rdunlap@xenotime.net" <rdunlap@xenotime.net>

--001636b42dc2ee70f904a6761836
Content-Type: text/plain; charset=ISO-8859-1

On Fri, Jun 24, 2011 at 1:05 AM, Rick van Rein <rick@vanrein.org> wrote:

> Hi Craig,
>
> > We (Google) are working on a data-driven answer for this question.  I
> know
> > that there has been some analysis on this topic on the past, but I don't
> > want to speculate until we've had some time to put all the pieces
> together.
>
> The easiest way to do this could be to take the algorithm from Memtest86
> and apply it to your data, to see if it finds suitable patterns for the
> cases tried.
>
> By counting bits set to zero in the masks, you could then determine how
> 'tight' they are.  A mask with all-ones covers one memory page; each
> zero bit in the mask (outside of the CPU's page size) doubles the number
> of pages covered.
>
> You can ignore the address over which the mask is applied, although you
> would then be assuming that all the pages covered by the mask are indeed
> filled with RAM.
>
> You would want to add the figures for the different masks.
>

This seems like a reasonable approach.  I know there was some analysis done,
and I'm doing my best to get the folks who made the original decision to
weigh in.


>
> I am very curious about your findings.  Independently of those, I am in
> favour of a patch that enables longer e820 tables if it has no further
> impact on speed or space.
>

I think that we'd all be satisfied with a mechanism that allows for badram
to be specified via both command line and an extended e820 map.


>
>
> Cheers,
>  -Rick
>

--001636b42dc2ee70f904a6761836
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Fri, Jun 24, 2011 at 1:05 AM, Rick va=
n Rein <span dir=3D"ltr">&lt;<a href=3D"mailto:rick@vanrein.org">rick@vanre=
in.org</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" style=3D"=
margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
Hi Craig,<br>
<div class=3D"im"><br>
&gt; We (Google) are working on a data-driven answer for this question. =A0=
I know<br>
&gt; that there has been some analysis on this topic on the past, but I don=
&#39;t<br>
&gt; want to speculate until we&#39;ve had some time to put all the pieces =
together.<br>
<br>
</div>The easiest way to do this could be to take the algorithm from Memtes=
t86<br>
and apply it to your data, to see if it finds suitable patterns for the<br>
cases tried.<br>
<br>
By counting bits set to zero in the masks, you could then determine how<br>
&#39;tight&#39; they are. =A0A mask with all-ones covers one memory page; e=
ach<br>
zero bit in the mask (outside of the CPU&#39;s page size) doubles the numbe=
r<br>
of pages covered.<br>
<br>
You can ignore the address over which the mask is applied, although you<br>
would then be assuming that all the pages covered by the mask are indeed<br=
>
filled with RAM.<br>
<br>
You would want to add the figures for the different masks.<br></blockquote>=
<div><br></div><div>This seems like a reasonable approach. =A0I know there =
was some analysis done, and I&#39;m doing my best to get the folks who made=
 the original decision to weigh in.</div>
<div>=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;=
border-left:1px #ccc solid;padding-left:1ex;">
<br>
I am very curious about your findings. =A0Independently of those, I am in<b=
r>
favour of a patch that enables longer e820 tables if it has no further<br>
impact on speed or space.<br></blockquote><div><br></div><div>I think that =
we&#39;d all be satisfied with a mechanism that allows for badram to be spe=
cified via both command line and an extended e820 map.</div><div>=A0</div>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex;">
<br>
<br>
Cheers,<br>
<font color=3D"#888888">=A0-Rick<br>
</font></blockquote></div><br>

--001636b42dc2ee70f904a6761836--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
