Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 7E15A900137
	for <linux-mm@kvack.org>; Tue, 30 Aug 2011 12:25:36 -0400 (EDT)
Received: by gwaa20 with SMTP id a20so6819930gwa.14
        for <linux-mm@kvack.org>; Tue, 30 Aug 2011 09:25:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAFPAmTQoVt+rg+2KHuu-Pi3t_RCx-14xFeMOamguMQMZFV==Jg@mail.gmail.com>
References: <CAJ8eaTyeQj5_EAsCFDMmDs3faiVptuccmq3VJLjG-QnYG038=A@mail.gmail.com>
	<CAJ8eaTw=dKUNE8h-HD7RWxXHcTEuxJH4AfcOO44RSF7QdC5arQ@mail.gmail.com>
	<CAHKQLBH2d-DzzMfP9QOUmz6brT7BfPdwY6JfEUUYxzaTDTo=wg@mail.gmail.com>
	<CAJ8eaTxmZm6yw1YWhdfaxwuf0mF+sOfX6RUPfcu-qiHYu+D4CA@mail.gmail.com>
	<CAJ8eaTz_zYYwG5HqTgU4=mbPwh=4rT9L-awJ-zO5QTsmP+GjOQ@mail.gmail.com>
	<CAFPAmTQoVt+rg+2KHuu-Pi3t_RCx-14xFeMOamguMQMZFV==Jg@mail.gmail.com>
Date: Tue, 30 Aug 2011 11:25:33 -0500
Message-ID: <CAHKQLBE9Vct8U3q7h1NQca7oqSOwHuxzrMgjiARkp=f22J1Lig@mail.gmail.com>
Subject: Re: Kernel panic in 2.6.35.12 kernel
From: Steve Chen <schen@mvista.com>
Content-Type: multipart/alternative; boundary=20cf303ea638f7948204abbb7577
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kautuk Consul <consul.kautuk@gmail.com>
Cc: naveen yadav <yad.naveen@gmail.com>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org

--20cf303ea638f7948204abbb7577
Content-Type: text/plain; charset=ISO-8859-1

On Tue, Aug 30, 2011 at 12:19 AM, Kautuk Consul <consul.kautuk@gmail.com>wrote:

> Hi Steve,
>
> I too have noticed this strange behaviour on my Linux ARM board.
>
> I also have 2.6.35.12 installed and I see a similar crash when
> parallel OOMs are triggerred.
>
> I am executing multiple instances of a similar test application which
> allocates a lot of anonymous memory.
> OOM then starts kicking in parallel and this eventualy results in a
> hang situation.
>
> Can anyone tell me what patch to apply to solve this problem ?
>
>
I'm really not familiar with OOM, so I don't know the answer.

Sorry,

Steve

--20cf303ea638f7948204abbb7577
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Tue, Aug 30, 2011 at 12:19 AM, Kautuk=
 Consul <span dir=3D"ltr">&lt;<a href=3D"mailto:consul.kautuk@gmail.com">co=
nsul.kautuk@gmail.com</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_q=
uote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1e=
x;">
Hi Steve,<br>
<br>
I too have noticed this strange behaviour on my Linux ARM board.<br>
<br>
I also have 2.6.35.12 installed and I see a similar crash when<br>
parallel OOMs are triggerred.<br>
<br>
I am executing multiple instances of a similar test application which<br>
allocates a lot of anonymous memory.<br>
OOM then starts kicking in parallel and this eventualy results in a<br>
hang situation.<br>
<br>
Can anyone tell me what patch to apply to solve this problem ?<br>
<br></blockquote></div><br>I&#39;m really not familiar with OOM, so I don&#=
39;t know the answer.<br><br>Sorry,<br><br>Steve<br>

--20cf303ea638f7948204abbb7577--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
