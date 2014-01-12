Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f49.google.com (mail-qe0-f49.google.com [209.85.128.49])
	by kanga.kvack.org (Postfix) with ESMTP id 9C92D6B0031
	for <linux-mm@kvack.org>; Sun, 12 Jan 2014 08:03:52 -0500 (EST)
Received: by mail-qe0-f49.google.com with SMTP id w4so3252810qeb.22
        for <linux-mm@kvack.org>; Sun, 12 Jan 2014 05:03:52 -0800 (PST)
Received: from mail-qc0-x231.google.com (mail-qc0-x231.google.com [2607:f8b0:400d:c01::231])
        by mx.google.com with ESMTPS id a3si7250570qey.20.2014.01.12.05.03.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 12 Jan 2014 05:03:51 -0800 (PST)
Received: by mail-qc0-f177.google.com with SMTP id i8so1999337qcq.8
        for <linux-mm@kvack.org>; Sun, 12 Jan 2014 05:03:51 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20140111183855.GA4407@cmpxchg.org>
References: <CANwX7LTkb3v6Aq9nqFWN-cykX08+fuAntFMDRu7DM_pcyK9iSw@mail.gmail.com>
	<20140111183855.GA4407@cmpxchg.org>
Date: Sun, 12 Jan 2014 21:03:51 +0800
Message-ID: <CANwX7LRPW5b3qy1=0e0OyWo+3bjGHwB-=YpCci+gnNQa9ST3yw@mail.gmail.com>
Subject: Re: [Help] Question about vm: fair zone allocator policy
From: yvxiang <linyvxiang@gmail.com>
Content-Type: multipart/alternative; boundary=001a11c2bd9e34042904efc59719
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org

--001a11c2bd9e34042904efc59719
Content-Type: text/plain; charset=ISO-8859-1

OK, I think I got it. Thank you very much!!


2014/1/12 Johannes Weiner <hannes@cmpxchg.org>

> On Tue, Jan 07, 2014 at 09:37:01AM +0800, yvxiang wrote:
> > Hi, Johannes
> >
> >      I'm a new comer to vm. And I read your commit 81c0a2bb about fair
> zone
> > allocator policy,  but I don't quite understand your opinion, especially
> > the words that
> >
> >    "the allocator may keep kswapd running while kswapd reclaim
> >     ensures that the page allocator can keep allocating from the first
> zone
> > in
> >     the zonelist for extended periods of time. "
> >
> >     Could you or someone else explain me what does this mean in more
> > details? Or could you give me a example?
>
> The page allocator tries to allocate from all zones in order of
> preference: Normal, DMA32, DMA.  If they are all at their low
> watermark, kswapd is woken up and it will reclaim each zone until it's
> back to the high watermark.
>
> But as kswapd reclaims the Normal zone, the page allocator can
> continue allocating from it.  If that happens at roughly the same
> pace, the Normal zone's watermark will hover somewhere between the low
> and high watermark.  Kswapd will not go to sleep and the page
> allocator will not use the other zones.
>
> The whole workload's memory will be allocated and reclaimed using only
> the Normal zone, which might be only a few (hundred) megabytes, while
> the 4G DMA32 zone is unused.
>

--001a11c2bd9e34042904efc59719
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">OK, I think I got it. Thank you very much!!</div><div clas=
s=3D"gmail_extra"><br><br><div class=3D"gmail_quote">2014/1/12 Johannes Wei=
ner <span dir=3D"ltr">&lt;<a href=3D"mailto:hannes@cmpxchg.org" target=3D"_=
blank">hannes@cmpxchg.org</a>&gt;</span><br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex"><div class=3D"HOEnZb"><div class=3D"h5">On T=
ue, Jan 07, 2014 at 09:37:01AM +0800, yvxiang wrote:<br>
&gt; Hi, Johannes<br>
&gt;<br>
&gt; =A0 =A0 =A0I&#39;m a new comer to vm. And I read your commit 81c0a2bb =
about fair zone<br>
&gt; allocator policy, =A0but I don&#39;t quite understand your opinion, es=
pecially<br>
&gt; the words that<br>
&gt;<br>
&gt; =A0 =A0&quot;the allocator may keep kswapd running while kswapd reclai=
m<br>
&gt; =A0 =A0 ensures that the page allocator can keep allocating from the f=
irst zone<br>
&gt; in<br>
&gt; =A0 =A0 the zonelist for extended periods of time. &quot;<br>
&gt;<br>
&gt; =A0 =A0 Could you or someone else explain me what does this mean in mo=
re<br>
&gt; details? Or could you give me a example?<br>
<br>
</div></div>The page allocator tries to allocate from all zones in order of=
<br>
preference: Normal, DMA32, DMA. =A0If they are all at their low<br>
watermark, kswapd is woken up and it will reclaim each zone until it&#39;s<=
br>
back to the high watermark.<br>
<br>
But as kswapd reclaims the Normal zone, the page allocator can<br>
continue allocating from it. =A0If that happens at roughly the same<br>
pace, the Normal zone&#39;s watermark will hover somewhere between the low<=
br>
and high watermark. =A0Kswapd will not go to sleep and the page<br>
allocator will not use the other zones.<br>
<br>
The whole workload&#39;s memory will be allocated and reclaimed using only<=
br>
the Normal zone, which might be only a few (hundred) megabytes, while<br>
the 4G DMA32 zone is unused.<br>
</blockquote></div><br></div>

--001a11c2bd9e34042904efc59719--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
