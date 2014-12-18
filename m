Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 5E2876B0070
	for <linux-mm@kvack.org>; Wed, 17 Dec 2014 19:38:29 -0500 (EST)
Received: by mail-wg0-f52.google.com with SMTP id x12so227548wgg.11
        for <linux-mm@kvack.org>; Wed, 17 Dec 2014 16:38:28 -0800 (PST)
Received: from mail-wg0-x234.google.com (mail-wg0-x234.google.com. [2a00:1450:400c:c00::234])
        by mx.google.com with ESMTPS id jk4si29835881wid.54.2014.12.17.16.38.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 17 Dec 2014 16:38:28 -0800 (PST)
Received: by mail-wg0-f52.google.com with SMTP id x12so227542wgg.11
        for <linux-mm@kvack.org>; Wed, 17 Dec 2014 16:38:28 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20141217150654.e857603cebd4f97c794a2dff@linux-foundation.org>
References: <1418560486-21685-1-git-send-email-nefelim4ag@gmail.com> <20141217150654.e857603cebd4f97c794a2dff@linux-foundation.org>
From: Timofey Titovets <nefelim4ag@gmail.com>
Date: Thu, 18 Dec 2014 03:37:48 +0300
Message-ID: <CAGqmi76snK8SMZx_j64WkHcBcixJM3_=jDOZTfihmPpT4zigog@mail.gmail.com>
Subject: Re: [PATCH] mempool.c: Replace io_schedule_timeout with io_schedule
Content-Type: multipart/alternative; boundary=047d7bea379290b93c050a72cf76
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org

--047d7bea379290b93c050a72cf76
Content-Type: text/plain; charset=UTF-8

2014-12-18 2:06 GMT+03:00 Andrew Morton <akpm@linux-foundation.org>:
>
> On Sun, 14 Dec 2014 15:34:46 +0300 Timofey Titovets <nefelim4ag@gmail.com>
> wrote:
>
> > io_schedule_timeout(5*HZ);
> > Introduced for avoidance dm bug:
> > http://linux.derkeiler.com/Mailing-Lists/Kernel/2006-08/msg04869.html
> > According to description must be replaced with io_schedule()
> >
> > I replace it and recompile kernel, tested it by following script:
>
> How do we know DM doesn't still depend on the io_schedule_timeout()?
>
> It would require input from the DM developers and quite a lot of
> stress-testing of many kernel subsystems before we could make this
> change.
>

Okay, sorry for noise, will talking with dm devels, and after, if all be
good, will resend it.

-- 
Have a nice day,
Timofey.

--047d7bea379290b93c050a72cf76
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_extra"><div class=3D"gmail_quote">2014=
-12-18 2:06 GMT+03:00 Andrew Morton <span dir=3D"ltr">&lt;<a href=3D"mailto=
:akpm@linux-foundation.org" target=3D"_blank">akpm@linux-foundation.org</a>=
&gt;</span>:<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;bo=
rder-left:1px #ccc solid;padding-left:1ex"><span>On Sun, 14 Dec 2014 15:34:=
46 +0300 Timofey Titovets &lt;<a href=3D"mailto:nefelim4ag@gmail.com" targe=
t=3D"_blank">nefelim4ag@gmail.com</a>&gt; wrote:<br>
<br>
&gt; io_schedule_timeout(5*HZ);<br>
&gt; Introduced for avoidance dm bug:<br>
&gt; <a href=3D"http://linux.derkeiler.com/Mailing-Lists/Kernel/2006-08/msg=
04869.html" target=3D"_blank">http://linux.derkeiler.com/Mailing-Lists/Kern=
el/2006-08/msg04869.html</a><br>
&gt; According to description must be replaced with io_schedule()<br>
&gt;<br>
&gt; I replace it and recompile kernel, tested it by following script:<br>
<br>
</span>How do we know DM doesn&#39;t still depend on the io_schedule_timeou=
t()?<br>
<br>
It would require input from the DM developers and quite a lot of<br>
stress-testing of many kernel subsystems before we could make this<br>
change.<br></blockquote></div><div><br></div><div>Okay, sorry for noise, wi=
ll talking with dm devels, and after, if all be good, will resend it.</div>=
<div><br></div>-- <br><div>Have a nice day,<br>Timofey.</div>
</div></div>

--047d7bea379290b93c050a72cf76--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
