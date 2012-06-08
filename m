Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 69D6D6B006E
	for <linux-mm@kvack.org>; Fri,  8 Jun 2012 04:48:07 -0400 (EDT)
Received: by yhr47 with SMTP id 47so1455955yhr.14
        for <linux-mm@kvack.org>; Fri, 08 Jun 2012 01:48:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4FD1BB29.1050805@kernel.org>
References: <CAHGf_=pSLfAue6AR5gi5RQ7xvgTxpZckA=Ja1fO1AkoO1o_DeA@mail.gmail.com>
	<CAOJsxLG1+zhOKgi2Rg1eSoXSCU8QGvHVED_EefOOLP-6JbMDkg@mail.gmail.com>
	<20120601122118.GA6128@lizard>
	<alpine.LFD.2.02.1206032125320.1943@tux.localdomain>
	<4FCC7592.9030403@kernel.org>
	<20120604113811.GA4291@lizard>
	<4FCD14F1.1030105@gmail.com>
	<CAOJsxLHR4wSgT2hNfOB=X6ud0rXgYg+h7PTHzAZYCUdLs6Ktug@mail.gmail.com>
	<20120605083921.GA21745@lizard>
	<4FD014D7.6000605@kernel.org>
	<20120608074906.GA27095@lizard>
	<4FD1BB29.1050805@kernel.org>
Date: Fri, 8 Jun 2012 11:48:06 +0300
Message-ID: <CAOJsxLHPvg=bsv+GakFGHyJwH0BoGA=fmzy5bwqWKNGryYTDtg@mail.gmail.com>
Subject: Re: [PATCH 0/5] Some vmevent fixes...
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Anton Vorontsov <anton.vorontsov@linaro.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

On Fri, Jun 8, 2012 at 11:43 AM, Minchan Kim <minchan@kernel.org> wrote:
>> So, the solution would be then two-fold:
>>
>> 1. Use your memory pressure notifications. They must be quite fast when
>> =A0 =A0we starting to feel the high pressure. (I see the you use
>> =A0 =A0zone_page_state() and friends, which is vm_stat, and it is update=
d
>
> VM has other information like nr_reclaimed, nr_scanned, nr_congested, rec=
ent_scanned,
> recent_rotated, too. I hope we can make math by them and improve as we im=
prove
> VM reclaimer.
>
>> =A0 =A0very infrequently, but to get accurate notification we have to
>> =A0 =A0update it much more frequently, but this is very expensive. So
>> =A0 =A0KOSAKI and Christoph will complain. :-)
>
>
> Reclaimer already have used that and if we need accuracy, we handled it
> like zone_watermark_ok_safe. If it's very inaccurate, VM should be fixed,=
 too.

Exactly. I don't know why people think pushing vmevents to userspace
is going to fix any of the hard problems.

Anton, Lenoid, do you see any fundamental issues from userspace point
of view with going forward what Minchan is proposing?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
