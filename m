Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id B07AC6B0047
	for <linux-mm@kvack.org>; Thu, 18 Feb 2010 20:59:46 -0500 (EST)
Received: by pxi31 with SMTP id 31so4433445pxi.26
        for <linux-mm@kvack.org>; Thu, 18 Feb 2010 17:59:45 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1266516162-14154-8-git-send-email-mel@csn.ul.ie>
References: <1266516162-14154-1-git-send-email-mel@csn.ul.ie>
	 <1266516162-14154-8-git-send-email-mel@csn.ul.ie>
Date: Fri, 19 Feb 2010 10:59:45 +0900
Message-ID: <28c262361002181759m35c0fd73k5f252953b4d0932@mail.gmail.com>
Subject: Re: [PATCH 07/12] Export fragmentation index via /proc/pagetypeinfo
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 19, 2010 at 3:02 AM, Mel Gorman <mel@csn.ul.ie> wrote:
> Fragmentation index is a value that makes sense when an allocation of a
> given size would fail. The index indicates whether an allocation failure =
is
> due to a lack of memory (values towards 0) or due to external fragmentati=
on
> (value towards 1). =C2=A0For the most part, the huge page size will be th=
e size
> of interest but not necessarily so it is exported on a per-order and per-=
zone
> basis via /proc/pagetypeinfo.
>
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
