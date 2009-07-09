Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 4FCB96B005C
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 06:25:34 -0400 (EDT)
Received: by gxk3 with SMTP id 3so89573gxk.14
        for <linux-mm@kvack.org>; Thu, 09 Jul 2009 03:41:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090709165820.23B7.A69D9226@jp.fujitsu.com>
References: <20090709165820.23B7.A69D9226@jp.fujitsu.com>
Date: Thu, 9 Jul 2009 19:41:23 +0900
Message-ID: <28c262360907090341x18c4e9d6n524ccf1eed6e417a@mail.gmail.com>
Subject: Re: [PATCH 0/5] OOM analysis helper patch series v2
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Lameter <cl@linux-foundation.org>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

Thanks for your effort :)

On Thu, Jul 9, 2009 at 5:05 PM, KOSAKI
Motohiro<kosaki.motohiro@jp.fujitsu.com> wrote:
>
> ChangeLog
> =C2=A0Since v1
> =C2=A0 - Droped "[5/5] add NR_ANON_PAGES to OOM log" patch
> =C2=A0 - Instead, introduce "[5/5] add shmem vmstat" patch
> =C2=A0 - Fixed unit bug (Thanks Minchan)
> =C2=A0 - Separated isolated vmstat to two field (Thanks Minchan and Wu)
> =C2=A0 - Fixed isolated page and lumpy reclaim issue (Thanks Minchan)
> =C2=A0 - Rewrote some patch description (Thanks Christoph)
>
>
> Current OOM log doesn't provide sufficient memory usage information. it c=
ause
> make confusion to lkml MM guys.
>
> this patch series add some memory usage information to OOM log.
>
>
>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =C2=A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
