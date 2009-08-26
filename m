Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 6A9FD6B004F
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 19:20:33 -0400 (EDT)
Received: by qyk1 with SMTP id 1so265637qyk.23
        for <linux-mm@kvack.org>; Wed, 26 Aug 2009 16:20:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <Pine.LNX.4.64.0908261050080.18633@sister.anvils>
References: <Pine.LNX.4.64.0908261050080.18633@sister.anvils>
Date: Thu, 27 Aug 2009 08:20:36 +0900
Message-ID: <28c262360908261620x3ca55167r872db2b91802d679@mail.gmail.com>
Subject: Re: [PATCH mmotm] mm: introduce page_lru_base_type fix
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 26, 2009 at 6:53 PM, Hugh Dickins<hugh.dickins@tiscali.co.uk> w=
rote:
> My usual tmpfs swapping loads on recent mmotms have oddly
> aroused the OOM killer after an hour or two. =C2=A0Bisection led to
> mm-return-boolean-from-page_is_file_cache.patch, but really it's
> the prior mm-introduce-page_lru_base_type.patch that's at fault.
>
> It converted page_lru() to use page_lru_base_type(), but forgot
> to convert del_page_from_lru() - which then decremented the wrong
> stats once page_is_file_cache() was changed to a boolean.
>
> Fix that, move page_lru_base_type() before del_page_from_lru(),
> and mark it "inline" like the other mm_inline.h functions.
>
> Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
