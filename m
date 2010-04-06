Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 173186B01EF
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 00:15:13 -0400 (EDT)
Received: by pzk30 with SMTP id 30so3593478pzk.12
        for <linux-mm@kvack.org>; Mon, 05 Apr 2010 21:15:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1270523356-1728-1-git-send-email-arve@android.com>
References: <20100405101424.GA21207@csn.ul.ie>
	 <1270523356-1728-1-git-send-email-arve@android.com>
Date: Tue, 6 Apr 2010 13:15:12 +0900
Message-ID: <k2g28c262361004052115ie21bd036hcbdbdb7750f2942b@mail.gmail.com>
Subject: Re: [PATCH] mm: Check if any page in a pageblock is reserved before
	marking it MIGRATE_RESERVE
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: =?UTF-8?B?QXJ2ZSBIasO4bm5ldsOlZw==?= <arve@android.com>
Cc: Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, TAO HU <tghk48@motorola.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Ye Yuan.Bo-A22116" <yuan-bo.ye@motorola.com>, Chang Qing-A21550 <Qing.Chang@motorola.com>, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 6, 2010 at 12:09 PM, Arve Hj=C3=B8nnev=C3=A5g <arve@android.com=
> wrote:
> This fixes a problem where the first pageblock got marked MIGRATE_RESERVE=
 even
> though it only had a few free pages. This in turn caused no contiguous me=
mory
> to be reserved and frequent kswapd wakeups that emptied the caches to get=
 more
> contiguous memory.

It would be better to add following your description of previous mail threa=
d.
It can help others understand it in future.

On Fri, Apr 02, 2010 at 05:59:00PM -0700, Arve Hj?nnev?g wrote:
...
"I think this happens by default on arm. The kernel starts at offset
0x8000 to leave room for boot parameters, and in recent kernel
versions (>~2.6.26-29) this memory is freed."


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
