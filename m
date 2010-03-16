Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 433AA6B0164
	for <linux-mm@kvack.org>; Mon, 15 Mar 2010 22:47:50 -0400 (EDT)
Received: by pvg2 with SMTP id 2so894564pvg.14
        for <linux-mm@kvack.org>; Mon, 15 Mar 2010 19:47:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1268412087-13536-11-git-send-email-mel@csn.ul.ie>
References: <1268412087-13536-1-git-send-email-mel@csn.ul.ie>
	 <1268412087-13536-11-git-send-email-mel@csn.ul.ie>
Date: Tue, 16 Mar 2010 11:47:48 +0900
Message-ID: <28c262361003151947p356578ffs3e7b73bc81214cfc@mail.gmail.com>
Subject: Re: [PATCH 10/11] Direct compact when a high-order allocation fails
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Mar 13, 2010 at 1:41 AM, Mel Gorman <mel@csn.ul.ie> wrote:
> Ordinarily when a high-order allocation fails, direct reclaim is entered =
to
> free pages to satisfy the allocation. =C2=A0With this patch, it is determ=
ined if
> an allocation failed due to external fragmentation instead of low memory
> and if so, the calling process will compact until a suitable page is
> freed. Compaction by moving pages in memory is considerably cheaper than
> paging out to disk and works where there are locked pages or no swap. If
> compaction fails to free a page of a suitable size, then reclaim will
> still occur.
>
> Direct compaction returns as soon as possible. As each block is compacted=
,
> it is checked if a suitable page has been freed and if so, it returns.
>
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> Acked-by: Rik van Riel <riel@redhat.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

At least, I can't find any fault more. :)

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
