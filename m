Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f172.google.com (mail-lb0-f172.google.com [209.85.217.172])
	by kanga.kvack.org (Postfix) with ESMTP id 16FF76B0254
	for <linux-mm@kvack.org>; Wed, 11 Nov 2015 11:19:49 -0500 (EST)
Received: by lbblt2 with SMTP id lt2so19631433lbb.3
        for <linux-mm@kvack.org>; Wed, 11 Nov 2015 08:19:48 -0800 (PST)
Received: from mail-lb0-x235.google.com (mail-lb0-x235.google.com. [2a00:1450:4010:c04::235])
        by mx.google.com with ESMTPS id pq8si6561002lbc.132.2015.11.11.08.19.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Nov 2015 08:19:47 -0800 (PST)
Received: by lbblt2 with SMTP id lt2so19631054lbb.3
        for <linux-mm@kvack.org>; Wed, 11 Nov 2015 08:19:47 -0800 (PST)
From: Arkadiusz =?utf-8?q?Mi=C5=9Bkiewicz?= <arekm@maven.pl>
Subject: Re: memory reclaim problems on fs usage
Date: Wed, 11 Nov 2015 17:19:42 +0100
References: <201511102313.36685.arekm@maven.pl> <5643658B.9090206@I-love.SAKURA.ne.jp>
In-Reply-To: <5643658B.9090206@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Message-Id: <201511111719.44035.arekm@maven.pl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: linux-mm@kvack.org, xfs@oss.sgi.com

On Wednesday 11 of November 2015, Tetsuo Handa wrote:
> On 2015/11/11 7:13, Arkadiusz Mi=C5=9Bkiewicz wrote:
> > The usual (repeatable) problem is like this:
> >=20
> > full dmesg: http://sprunge.us/VEiE (more in it then in partial log belo=
w)
>=20
> Maybe somebody doing GFP_NOIO allocation which XFS driver doing GFP_NOFS
> allocation is waiting for is stalling inside memory allocator. I think th=
at
> checking tasks which are stalling inside memory allocator would help.
>=20
> Please try reproducing this problem with a debug printk() patch shown bel=
ow
> applied. This is a patch which I used for debugging silent lockup problem.
> When memory allocation got stuck, lines with MemAlloc keyword will be
> printed.
>=20
> ---
>   fs/xfs/kmem.c          |  10 ++-
>   fs/xfs/xfs_buf.c       |   3 +-
>   include/linux/mmzone.h |   1 +
>   include/linux/vmstat.h |   1 +
>   mm/page_alloc.c        | 217
> +++++++++++++++++++++++++++++++++++++++++++++++++ mm/vmscan.c            |
>  22 +++++
>   6 files changed, 249 insertions(+), 5 deletions(-)

This patch is against which tree? (tried 4.1, 4.2 and 4.3)

=2D-=20
Arkadiusz Mi=C5=9Bkiewicz, arekm / ( maven.pl | pld-linux.org )

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
