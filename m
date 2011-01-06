Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 43E846B0088
	for <linux-mm@kvack.org>; Thu,  6 Jan 2011 10:10:55 -0500 (EST)
Received: by qwa26 with SMTP id 26so16769006qwa.14
        for <linux-mm@kvack.org>; Thu, 06 Jan 2011 07:10:49 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110106104611.GF29257@csn.ul.ie>
References: <AANLkTikrPWqH1tiG4Hx8eg09+Sn_cJ=EMbBVWrSabCF1@mail.gmail.com>
	<20110106104611.GF29257@csn.ul.ie>
Date: Thu, 6 Jan 2011 15:10:49 +0000
Message-ID: <AANLkTik8YyhX+pceEWk5zfg2HtP8+zaGwHV_ZmUuOnbk@mail.gmail.com>
Subject: Re: CLOCK-Pro algorithm
From: Adrian McMenamin <adrianmcmenamin@gmail.com>
Content-Type: multipart/alternative; boundary=0016e64cbd36288bdf04992ee8b9
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Adrian McMenamin <lkmladrian@gmail.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--0016e64cbd36288bdf04992ee8b9
Content-Type: text/plain; charset=ISO-8859-1

On 6 January 2011 10:46, Mel Gorman <mel@csn.ul.ie> wrote:

>
>
> The current reclaim algorithm is a mash of a number of different
> algorithms with a number of modifications for catching corner cases and
> various optimisations. In terms of an MSc, your best bet is to do a
> general literature review of replacement algorithms and then do your
> best to write a short paper describing the Linux page replacement
> algorithm identifying which replacement algorithms it takes lessons
> from.
>
>
Thanks for this - I am indeed reading through the various papers and other
literature (and I bought your book), though my aim with the MSc project is
slightly more abitious than maybe you are suggesting: I want to look at how
important some of the issues that are identified as common problems with
global clock and similar replacement algorithms (eg a slow response to
changes in locality) and to test whether there are some heuristics from
local replacement policies that might address them, at least in theory.

The Clock-Pro paper was an interesting read and given its claims for
improvement in the 2.4 series kernels I was interested in seeing how far the
idea had got in the 2.6 series.

Adrian

--0016e64cbd36288bdf04992ee8b9
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br>
<div class=3D"gmail_quote">On 6 January 2011 10:46, Mel Gorman <span dir=3D=
"ltr">&lt;<a href=3D"mailto:mel@csn.ul.ie">mel@csn.ul.ie</a>&gt;</span> wro=
te:<br>
<blockquote style=3D"BORDER-LEFT: #ccc 1px solid; MARGIN: 0px 0px 0px 0.8ex=
; PADDING-LEFT: 1ex" class=3D"gmail_quote">
<div>
<div></div>
<div class=3D"h5"><br>=A0</div></div>The current reclaim algorithm is a mas=
h of a number of different<br>algorithms with a number of modifications for=
 catching corner cases and<br>various optimisations. In terms of an MSc, yo=
ur best bet is to do a<br>
general literature review of replacement algorithms and then do your<br>bes=
t to write a short paper describing the Linux page replacement<br>algorithm=
 identifying which replacement algorithms it takes lessons<br>from.<br>
<font color=3D"#888888"><br></font></blockquote>
<div>=A0</div>
<div>Thanks for this - I am indeed reading through the various papers and o=
ther literature=A0(and I bought your book), though my aim with the MSc proj=
ect is slightly more abitious than maybe you are suggesting: I want to look=
 at how important some of the issues that are identified as common problems=
 with global clock and similar replacement algorithms (eg=A0a slow response=
 to changes in locality) and to test whether there are some heuristics from=
 local replacement policies that might address them, at least in theory.</d=
iv>

<div>=A0</div>
<div>The Clock-Pro paper was an interesting read and given its claims for i=
mprovement in the 2.4 series kernels I was interested in seeing how far the=
 idea had got in the 2.6 series.</div>
<div>=A0</div>
<div>Adrian</div></div>

--0016e64cbd36288bdf04992ee8b9--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
