Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1EC2D900086
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 02:23:50 -0400 (EDT)
Received: by iyh42 with SMTP id 42so2907214iyh.14
        for <linux-mm@kvack.org>; Thu, 14 Apr 2011 23:23:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1302847688-8076-1-git-send-email-namhyung@gmail.com>
References: <BANLkTinDFrbUNPnUmed2aBTu1_QHFQie-w@mail.gmail.com>
	<1302847688-8076-1-git-send-email-namhyung@gmail.com>
Date: Fri, 15 Apr 2011 15:23:48 +0900
Message-ID: <BANLkTik_ztG7JsuskO=umc1A0466P7HvKg@mail.gmail.com>
Subject: Re: [PATCH v2] mempolicy: reduce references to the current
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Namhyung Kim <namhyung@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Apr 15, 2011 at 3:08 PM, Namhyung Kim <namhyung@gmail.com> wrote:
> Remove duplicated reference to the 'current' task using a local
> variable. Since refering the current can be a burden, it'd better
> cache the reference, IMHO. At least this saves some bytes on x86_64.
>
> =C2=A0$ size mempolicy-{old,new}.o
> =C2=A0 =C2=A0 text =C2=A0 =C2=A0data =C2=A0 =C2=A0bss =C2=A0 =C2=A0 dec =
=C2=A0 =C2=A0 hex filename
> =C2=A0 =C2=A025203 =C2=A0 =C2=A02448 =C2=A0 9176 =C2=A0 36827 =C2=A0 =C2=
=A08fdb mempolicy-old.o
> =C2=A0 =C2=A025136 =C2=A0 =C2=A02448 =C2=A0 9184 =C2=A0 36768 =C2=A0 =C2=
=A08fa0 mempolicy-new.o
>
> Signed-off-by: Namhyung Kim <namhyung@gmail.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
