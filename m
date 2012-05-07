Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id EC3D06B0044
	for <linux-mm@kvack.org>; Mon,  7 May 2012 03:14:34 -0400 (EDT)
Received: by yenm8 with SMTP id m8so5537797yen.14
        for <linux-mm@kvack.org>; Mon, 07 May 2012 00:14:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120504073810.GA25175@lizard>
References: <20120501132409.GA22894@lizard>
	<20120501132620.GC24226@lizard>
	<4FA35A85.4070804@kernel.org>
	<20120504073810.GA25175@lizard>
Date: Mon, 7 May 2012 10:14:33 +0300
Message-ID: <CAOJsxLH_7mMMe+2DvUxBW1i5nbUfkbfRE3iEhLQV9F_MM7=eiw@mail.gmail.com>
Subject: Re: [PATCH 3/3] vmevent: Implement special low-memory attribute
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton.vorontsov@linaro.org>
Cc: Minchan Kim <minchan@kernel.org>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

On Fri, May 4, 2012 at 10:38 AM, Anton Vorontsov
<anton.vorontsov@linaro.org> wrote:
> There are two problems.
>
> 1. Originally, the idea behind vmevent was that we should not expose all
> =A0 these mm details in vmevent, because it ties ABI with Linux internal
> =A0 memory representation;
>
> 2. If you have say a boolean '(A + B + C + ...) > X' attribute (which is
> =A0 exactly what blended attributes are), you can't just set up independe=
nt
> =A0 thresholds on A, B, C, ... and have the same effect.
>
> =A0 (What we can do, though, is... introduce arithmetic operators in
> =A0 vmevent. :-D But then, at the end, we'll probably implement in-kernel
> =A0 forth-like stack machine, with vmevent_config array serving as a
> =A0 sequence of op-codes. ;-)
>
> If we'll give up on "1." (Pekka, ping), then we need to solve "2."
> in a sane way: we'll have to add a 'NR_FILE_PAGES - NR_SHMEM -
> <todo-locked-file-pages>' attribute, and give it a name.

Well, no, we can't give up on (1) completely. That'd mean that
eventually we'd need to change the ABI and break userspace. The
difference between exposing internal details and reasonable
abstractions is by no means black and white.

AFAICT, RECLAIMABLE_CACHE_PAGES is a reasonable thing to support. Can
anyone come up with a reason why we couldn't do that in the future?

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
