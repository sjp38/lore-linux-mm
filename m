Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 94DC96B0082
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 00:10:21 -0400 (EDT)
Received: by yxe35 with SMTP id 35so2754333yxe.12
        for <linux-mm@kvack.org>; Wed, 15 Jul 2009 21:10:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090716095241.9D0D.A69D9226@jp.fujitsu.com>
References: <20090716094619.9D07.A69D9226@jp.fujitsu.com>
	 <20090716095241.9D0D.A69D9226@jp.fujitsu.com>
Date: Thu, 16 Jul 2009 13:10:23 +0900
Message-ID: <28c262360907152110k23e1aebk9fbf7853c29991e@mail.gmail.com>
Subject: Re: [PATCH 2/3] mm: shrink_inactive_lis() nr_scan accounting fix fix
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Good.
I decided making patch like this since I knew this problem.
You are too diligent :)

Thanks for good attitude.

On Thu, Jul 16, 2009 at 9:53 AM, KOSAKI
Motohiro<kosaki.motohiro@jp.fujitsu.com> wrote:
> Subject: [PATCH] mm: shrink_inactive_lis() nr_scan accounting fix fix
>
> If sc->isolate_pages() return 0, we don't need to call shrink_page_list()=
.
> In past days, shrink_inactive_list() handled it properly.
>
> But commit fb8d14e1 (three years ago commit!) breaked it. current shrink_=
inactive_list()
> always call shrink_page_list() although isolate_pages() return 0.
>
> This patch restore proper return value check.
>
>
> Requirements:
> =C2=A0o "nr_taken =3D=3D 0" condition should stay before calling shrink_p=
age_list().
> =C2=A0o "nr_taken =3D=3D 0" condition should stay after nr_scan related s=
tatistics
> =C2=A0 =C2=A0 modification.
>
>
> Cc: Wu Fengguang <fengguang.wu@intel.com>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
