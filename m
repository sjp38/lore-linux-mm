Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id 43FCA6B0035
	for <linux-mm@kvack.org>; Mon,  4 Nov 2013 20:40:58 -0500 (EST)
Received: by mail-pb0-f54.google.com with SMTP id ro12so2426070pbb.41
        for <linux-mm@kvack.org>; Mon, 04 Nov 2013 17:40:57 -0800 (PST)
Received: from psmtp.com ([74.125.245.201])
        by mx.google.com with SMTP id tu7si10157020pab.336.2013.11.04.17.40.56
        for <linux-mm@kvack.org>;
        Mon, 04 Nov 2013 17:40:57 -0800 (PST)
Received: by mail-oa0-f46.google.com with SMTP id g12so8004903oah.19
        for <linux-mm@kvack.org>; Mon, 04 Nov 2013 17:40:55 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20131026091112.241da260@notabene.brown>
References: <160824051.3072.1382685914055.JavaMail.mail@webmail07>
	<20131025214952.3eb41201@notabene.brown>
	<alpine.DEB.2.02.1310250425270.22538@nftneq.ynat.uz>
	<154617470.12445.1382725583671.JavaMail.mail@webmail11>
	<20131026074349.0adc9646@notabene.brown>
	<476525596.14731.1382735024280.JavaMail.mail@webmail11>
	<20131026091112.241da260@notabene.brown>
Date: Tue, 5 Nov 2013 09:40:55 +0800
Message-ID: <CAF7GXvpJVLYDS5NfH-NVuN9bOJjAS5c1MQqSTjoiVBHJt6bWcw@mail.gmail.com>
Subject: Re: Disabling in-memory write cache for x86-64 in Linux II
From: "Figo.zhang" <figo1802@gmail.com>
Content-Type: multipart/alternative; boundary=047d7b5d98e9a21ba204ea641f13
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.de>
Cc: "Artem S. Tashkinov" <t.artem@lycos.com>, david@lang.hm, lkml <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-fsdevel@vger.kernel.org, axboe@kernel.dk, Linux-MM <linux-mm@kvack.org>

--047d7b5d98e9a21ba204ea641f13
Content-Type: text/plain; charset=ISO-8859-1

> >
> > Of course, if you don't use Linux on the desktop you don't really care -
> well, I do. Also
> > not everyone in this world has an UPS - which means such a huge buffer
> can lead to a
> > serious data loss in case of a power blackout.
>
> I don't have a desk (just a lap), but I use Linux on all my computers and
> I've never really noticed the problem.  Maybe I'm just very patient, or
> maybe
> I don't work with large data sets and slow devices.
>
> However I don't think data-loss is really a related issue.  Any process
> that
> cares about data safety *must* use fsync at appropriate places.  This has
> always been true.
>
> =>May i ask question that, some like ext4 filesystem, if some app motify
the files, it create some dirty data. if some meta-data writing to the
journal disk when a power backout,
it will be lose some serious data and the the file will damage?

--047d7b5d98e9a21ba204ea641f13
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><div class=3D"gmail_extra"><div class=3D"gmail_quote">=
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex"><div class=3D"im">
&gt;<br>
&gt; Of course, if you don&#39;t use Linux on the desktop you don&#39;t rea=
lly care - well, I do. Also<br>
&gt; not everyone in this world has an UPS - which means such a huge buffer=
 can lead to a<br>
&gt; serious data loss in case of a power blackout.<br>
<br>
</div>I don&#39;t have a desk (just a lap), but I use Linux on all my compu=
ters and<br>
I&#39;ve never really noticed the problem. =A0Maybe I&#39;m just very patie=
nt, or maybe<br>
I don&#39;t work with large data sets and slow devices.<br>
<br>
However I don&#39;t think data-loss is really a related issue. =A0Any proce=
ss that<br>
cares about data safety *must* use fsync at appropriate places. =A0This has=
<br>
always been true.<br><br></blockquote><div>=3D&gt;May i ask question that, =
some like ext4 filesystem, if some app motify the files, it create some dir=
ty data. if some meta-data writing to the journal disk when a power backout=
,=A0</div>
<div>it will be lose some serious data and the the file will damage?</div><=
/div></div></div>

--047d7b5d98e9a21ba204ea641f13--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
