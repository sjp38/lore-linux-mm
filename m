Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id D833E6B002D
	for <linux-mm@kvack.org>; Wed, 14 Sep 2011 21:51:50 -0400 (EDT)
Received: by vwm42 with SMTP id 42so3815829vwm.14
        for <linux-mm@kvack.org>; Wed, 14 Sep 2011 18:51:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1316050363.8425.483.camel@debian>
References: <1315188460.31737.5.camel@debian>
	<alpine.DEB.2.00.1109061914440.18646@router.home>
	<1315357399.31737.49.camel@debian>
	<alpine.DEB.2.00.1109062022100.20474@router.home>
	<4E671E5C.7010405@cs.helsinki.fi>
	<6E3BC7F7C9A4BF4286DD4C043110F30B5D00DA333C@shsmsx502.ccr.corp.intel.com>
	<alpine.DEB.2.00.1109071003240.9406@router.home>
	<1315442639.31737.224.camel@debian>
	<alpine.DEB.2.00.1109081336320.14787@router.home>
	<1315557944.31737.782.camel@debian>
	<1315902583.31737.848.camel@debian>
	<CALmdxiMuF6Q0W4ZdvhK5c4fQs8wUjcVGWYGWBjJi7WOfLYX=Gw@mail.gmail.com>
	<1316050363.8425.483.camel@debian>
Date: Wed, 14 Sep 2011 20:51:49 -0500
Message-ID: <CALmdxiMrDNDvhAmi88-0-1KBdyTwExZPy3Fh9_5TxB+XhK7vjw@mail.gmail.com>
Subject: Re: [PATCH] slub Discard slab page only when node partials > minimum setting
From: Christoph Lameter <christoph@lameter.com>
Content-Type: multipart/alternative; boundary=20cf3071ce3cbd029704acf11e1d
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Alex,Shi" <alex.shi@intel.com>
Cc: Christoph Lameter <cl@linux.com>, "penberg@kernel.org" <penberg@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Huang, Ying" <ying.huang@intel.com>, "Li, Shaohua" <shaohua.li@intel.com>, "Chen, Tim C" <tim.c.chen@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

--20cf3071ce3cbd029704acf11e1d
Content-Type: text/plain; charset=ISO-8859-1

I have not had time to get into this. I was hoping you could come up with
something.

On Wed, Sep 14, 2011 at 8:32 PM, Alex,Shi <alex.shi@intel.com> wrote:

> On Tue, 2011-09-13 at 23:04 +0800, Christoph Lameter wrote:
> > Sorry to be that late with a response but my email setup is screwed
> > up.
> >
> > I was more thinking about the number of slab pages in the partial
> > caches rather than the size of the objects itself being an issue. I
> > believe that was /sys/kernel/slab/*/cpu_partial.
> >
> > That setting could be tuned further before merging. An increase there
> > causes additional memory to be caught in the partial list. But it
> > reduces the node lock pressure further.
> >
>
> Yeah, I think so. The more cpu partial page, the quicker to getting
> slabs. Maybe it's better to considerate the system memory size to set
> them. Do you has some plan or suggestions on tunning?
>
>
>
>
>

--20cf3071ce3cbd029704acf11e1d
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

I have not had time to get into this. I was hoping you could come up with s=
omething.=A0<br><br><div class=3D"gmail_quote">On Wed, Sep 14, 2011 at 8:32=
 PM, Alex,Shi <span dir=3D"ltr">&lt;<a href=3D"mailto:alex.shi@intel.com">a=
lex.shi@intel.com</a>&gt;</span> wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex;"><div class=3D"im">On Tue, 2011-09-13 at 23:=
04 +0800, Christoph Lameter wrote:<br>
&gt; Sorry to be that late with a response but my email setup is screwed<br=
>
&gt; up.<br>
&gt;<br>
&gt; I was more thinking about the number of slab pages in the partial<br>
&gt; caches rather than the size of the objects itself being an issue. I<br=
>
&gt; believe that was /sys/kernel/slab/*/cpu_partial.<br>
&gt;<br>
&gt; That setting could be tuned further before merging. An increase there<=
br>
&gt; causes additional memory to be caught in the partial list. But it<br>
&gt; reduces the node lock pressure further.<br>
&gt;<br>
<br>
</div>Yeah, I think so. The more cpu partial page, the quicker to getting<b=
r>
slabs. Maybe it&#39;s better to considerate the system memory size to set<b=
r>
them. Do you has some plan or suggestions on tunning?<br>
<br>
<br>
<br>
<br>
</blockquote></div><br>

--20cf3071ce3cbd029704acf11e1d--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
