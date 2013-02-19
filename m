Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id A130C6B0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2013 02:10:18 -0500 (EST)
Received: by mail-la0-f53.google.com with SMTP id fr10so6163653lab.40
        for <linux-mm@kvack.org>; Mon, 18 Feb 2013 23:10:16 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAFNq8R5q7=wx6WgDwYUrgntMfewHEU=YHTCG4CZp3JcYZsCzhw@mail.gmail.com>
References: <CAHbM+PPcATz+QdY3=8ns_oFnv5vNi_NerU8hLnQ-EPVDwqSQpw@mail.gmail.com>
	<CAFNq8R5q7=wx6WgDwYUrgntMfewHEU=YHTCG4CZp3JcYZsCzhw@mail.gmail.com>
Date: Tue, 19 Feb 2013 12:40:15 +0530
Message-ID: <CAHbM+PNL+m098RWZN1EjYeLh-kLUsoOJAYBDXecmJ0-ci7oYgA@mail.gmail.com>
Subject: Re: A noobish question on mm
From: Soham Chakraborty <sohamwonderpiku4u@gmail.com>
Content-Type: multipart/alternative; boundary=f46d04343d3c962f4504d60e8805
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Haifeng <omycle@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org

--f46d04343d3c962f4504d60e8805
Content-Type: text/plain; charset=ISO-8859-1

On Tue, Feb 19, 2013 at 12:08 PM, Li Haifeng <omycle@gmail.com> wrote:

> 2013/2/19 Soham Chakraborty <sohamwonderpiku4u@gmail.com>:
> > Hey dude,
> >
> > Apologies for this kind of approach but I was not sure whether I can
> > directly mail the list with such a noobish question. I have been poking
> > around in mm subsystem for around 2 years now and I have never got a
> fine,
> > bullet proof answer to this question.
> >
> > Why would something swap even if there is free or cached memory
> available.
>
> It's known that swap operation is done with memory reclaiming.There
> are three occasions for memory reclaiming: low on memory reclaiming,
> Hibernation reclaiming, periodic reclaiming.
>
> For periodic reclaiming, some page may be swapped out even if there is
> free or cached memory available.
>

So, meaning even if there is free or cached memory available, periodic
reclaiming might cause some pages to be swapped out. Is this the rationale.
If so, which part of the source explains this behavior


> Please correct me if my understanding is wrong.
>
> Regards,
> Haifeng Li
> >
> > I have read about all possible theories including lru algorithm,
> > vm.swappiness, kernel heuristics, overcommit of memory and all. But I for
> > the heck of me, can't understand what is the issue. And I can't make the
> end
> > users satisfied too. I keep blabbering kernel heuristics too much.
> >
> > Do you have any answer to this question. If you think this is worthy of
> > going to list, I will surely do so.
> >
> > Soham
>

--f46d04343d3c962f4504d60e8805
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Tue, Feb 19, 2013 at 12:08 PM, Li Hai=
feng <span dir=3D"ltr">&lt;<a href=3D"mailto:omycle@gmail.com" target=3D"_b=
lank">omycle@gmail.com</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_=
quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1=
ex">
2013/2/19 Soham Chakraborty &lt;<a href=3D"mailto:sohamwonderpiku4u@gmail.c=
om">sohamwonderpiku4u@gmail.com</a>&gt;:<br>
<div class=3D"im">&gt; Hey dude,<br>
&gt;<br>
&gt; Apologies for this kind of approach but I was not sure whether I can<b=
r>
&gt; directly mail the list with such a noobish question. I have been pokin=
g<br>
&gt; around in mm subsystem for around 2 years now and I have never got a f=
ine,<br>
&gt; bullet proof answer to this question.<br>
&gt;<br>
&gt; Why would something swap even if there is free or cached memory availa=
ble.<br>
<br>
</div>It&#39;s known that swap operation is done with memory reclaiming.The=
re<br>
are three occasions for memory reclaiming: low on memory reclaiming,<br>
Hibernation reclaiming, periodic reclaiming.<br>
<br>
For periodic reclaiming, some page may be swapped out even if there is<br>
<div class=3D"im">free or cached memory available.<br></div></blockquote><d=
iv><br></div><div>So, meaning even if there is free or cached memory availa=
ble, periodic reclaiming might cause some pages to be swapped out. Is this =
the rationale. If so, which part of the source explains this=A0behavior=A0 =
=A0</div>
<div><br></div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex=
;border-left:1px #ccc solid;padding-left:1ex"><div class=3D"im">
<br>
</div>Please correct me if my understanding is wrong.<br>
<br>
Regards,<br>
Haifeng Li<br>
<div class=3D"HOEnZb"><div class=3D"h5">&gt;<br>
&gt; I have read about all possible theories including lru algorithm,<br>
&gt; vm.swappiness, kernel heuristics, overcommit of memory and all. But I =
for<br>
&gt; the heck of me, can&#39;t understand what is the issue. And I can&#39;=
t make the end<br>
&gt; users satisfied too. I keep blabbering kernel heuristics too much.<br>
&gt;<br>
&gt; Do you have any answer to this question. If you think this is worthy o=
f<br>
&gt; going to list, I will surely do so.<br>
&gt;<br>
&gt; Soham<br>
</div></div></blockquote></div><br>

--f46d04343d3c962f4504d60e8805--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
