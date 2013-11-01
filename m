Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 2CE3F6B0036
	for <linux-mm@kvack.org>; Thu, 31 Oct 2013 20:25:28 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id kp14so3316219pab.1
        for <linux-mm@kvack.org>; Thu, 31 Oct 2013 17:25:27 -0700 (PDT)
Received: from psmtp.com ([74.125.245.138])
        by mx.google.com with SMTP id mj9si3478562pab.335.2013.10.31.17.25.26
        for <linux-mm@kvack.org>;
        Thu, 31 Oct 2013 17:25:27 -0700 (PDT)
Received: by mail-ie0-f177.google.com with SMTP id e14so6178582iej.22
        for <linux-mm@kvack.org>; Thu, 31 Oct 2013 17:25:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5272E8EB.5030900@codeaurora.org>
References: <526844E6.1080307@codeaurora.org>
	<52686FF4.5000303@oracle.com>
	<5269BCCC.6090509@codeaurora.org>
	<CAA25o9R_jAZyGFU3xYVjsxCCiBwiEC4gRw+JX6WG9X7G-E3LNw@mail.gmail.com>
	<5272E8EB.5030900@codeaurora.org>
Date: Thu, 31 Oct 2013 17:25:25 -0700
Message-ID: <CAA25o9S=t_-25CoVqJQ5111Cix9UaDkQtqzqVhtYZT5e-DhUKw@mail.gmail.com>
Subject: Re: zram/zsmalloc issues in very low memory conditions
From: Luigi Semenzato <semenzato@google.com>
Content-Type: multipart/alternative; boundary=047d7bdc10ec44951604ea129aa3
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Olav Haugan <ohaugan@codeaurora.org>, Stephen Barber <smbarber@stanford.edu>
Cc: Bob Liu <bob.liu@oracle.com>, Minchan Kim <minchan@kernel.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

--047d7bdc10ec44951604ea129aa3
Content-Type: text/plain; charset=ISO-8859-1

Hi Olav,

I haven't personally done it.  Seth outlines the configuration in this
thread:

http://thread.gmane.org/gmane.linux.kernel.mm/105378/focus=105543

Stephen, can you add more detail from your experience?

Thanks!
Luigi




On Thu, Oct 31, 2013 at 4:34 PM, Olav Haugan <ohaugan@codeaurora.org> wrote:

> Hi Luigi,
>
> On 10/24/2013 6:12 PM, Luigi Semenzato wrote:
> > On Thu, Oct 24, 2013 at 5:35 PM, Olav Haugan <ohaugan@codeaurora.org>
> wrote:
> >> Hi Bob, Luigi,
> >>
> >> On 10/23/2013 5:55 PM, Bob Liu wrote:
> >>>
> >>> On 10/24/2013 05:51 AM, Olav Haugan wrote:
> >>
> >>> By the way, could you take a try with zswap? Which can write pages to
> >>> real swap device if compressed pool is full.
> >>
> >> zswap might not be feasible in all cases if you only have flash as
> >> backing storage.
> >
> > Zswap can be configured to run without a backing storage.
> >
>
> I was under the impression that zswap requires a backing storage. Can
> you elaborate on how to configure zswap to not need a backing storage?
>
>
> Olav Haugan
>
> --
> The Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
> hosted by The Linux Foundation
>

--047d7bdc10ec44951604ea129aa3
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div>Hi Olav,</div><div><br></div><div>I haven&#39;t perso=
nally done it. =A0Seth outlines the configuration in this thread:</div><div=
><br></div><a href=3D"http://thread.gmane.org/gmane.linux.kernel.mm/105378/=
focus=3D105543">http://thread.gmane.org/gmane.linux.kernel.mm/105378/focus=
=3D105543</a><br>
<div><br></div><div>Stephen, can you add more detail from your experience?<=
/div><div><br></div><div>Thanks!</div><div>Luigi</div><div><br></div><div><=
br></div></div><div class=3D"gmail_extra"><br><br><div class=3D"gmail_quote=
">
On Thu, Oct 31, 2013 at 4:34 PM, Olav Haugan <span dir=3D"ltr">&lt;<a href=
=3D"mailto:ohaugan@codeaurora.org" target=3D"_blank">ohaugan@codeaurora.org=
</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" style=3D"margin=
:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
Hi Luigi,<br>
<div class=3D"im"><br>
On 10/24/2013 6:12 PM, Luigi Semenzato wrote:<br>
&gt; On Thu, Oct 24, 2013 at 5:35 PM, Olav Haugan &lt;<a href=3D"mailto:oha=
ugan@codeaurora.org">ohaugan@codeaurora.org</a>&gt; wrote:<br>
&gt;&gt; Hi Bob, Luigi,<br>
&gt;&gt;<br>
&gt;&gt; On 10/23/2013 5:55 PM, Bob Liu wrote:<br>
&gt;&gt;&gt;<br>
&gt;&gt;&gt; On 10/24/2013 05:51 AM, Olav Haugan wrote:<br>
&gt;&gt;<br>
</div><div class=3D"im">&gt;&gt;&gt; By the way, could you take a try with =
zswap? Which can write pages to<br>
&gt;&gt;&gt; real swap device if compressed pool is full.<br>
&gt;&gt;<br>
&gt;&gt; zswap might not be feasible in all cases if you only have flash as=
<br>
&gt;&gt; backing storage.<br>
&gt;<br>
&gt; Zswap can be configured to run without a backing storage.<br>
&gt;<br>
<br>
</div>I was under the impression that zswap requires a backing storage. Can=
<br>
you elaborate on how to configure zswap to not need a backing storage?<br>
<div class=3D"HOEnZb"><div class=3D"h5"><br>
<br>
Olav Haugan<br>
<br>
--<br>
The Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,<br>
hosted by The Linux Foundation<br>
</div></div></blockquote></div><br></div>

--047d7bdc10ec44951604ea129aa3--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
