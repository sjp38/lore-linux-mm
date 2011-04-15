Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id C123B900086
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 01:41:50 -0400 (EDT)
Received: by iwg8 with SMTP id 8so2883092iwg.14
        for <linux-mm@kvack.org>; Thu, 14 Apr 2011 22:41:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1302842039-7190-1-git-send-email-namhyung@gmail.com>
References: <1302842039-7190-1-git-send-email-namhyung@gmail.com>
Date: Fri, 15 Apr 2011 14:41:47 +0900
Message-ID: <BANLkTinDFrbUNPnUmed2aBTu1_QHFQie-w@mail.gmail.com>
Subject: Re: [PATCH] mempolicy: reduce references to the current
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Namhyung Kim <namhyung@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Apr 15, 2011 at 1:33 PM, Namhyung Kim <namhyung@gmail.com> wrote:
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

Hi Namhyung,

The patch looks good to me. :)
But I have a nitpick. "curr" is rather awkward to me.
We have been used "tsk" and "p" instead of "curr" for task_struct.
But I don't like "p" since it has no meaning. So for consistency,
could you change it with "tsk"?

Thanks.
--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
