Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f199.google.com (mail-yb0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id 43A1283092
	for <linux-mm@kvack.org>; Thu, 18 Aug 2016 09:22:43 -0400 (EDT)
Received: by mail-yb0-f199.google.com with SMTP id x37so35276324ybh.3
        for <linux-mm@kvack.org>; Thu, 18 Aug 2016 06:22:43 -0700 (PDT)
Received: from shelob.surriel.com (shelob.surriel.com. [2002:4a5c:3b41:1:216:3eff:fe57:7f4])
        by mx.google.com with ESMTPS id q43si1213775qta.58.2016.08.18.06.22.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 18 Aug 2016 06:22:42 -0700 (PDT)
Message-ID: <1471526527.2581.2.camel@surriel.com>
Subject: Re: [PATCH v2 2/2] fs: super.c: Add tracepoint to get name of
 superblock shrinker
From: Rik van Riel <riel@surriel.com>
Date: Thu, 18 Aug 2016 09:22:07 -0400
In-Reply-To: <20160818063239.GO2356@ZenIV.linux.org.uk>
References: <cover.1471496832.git.janani.rvchndrn@gmail.com>
 <600943d0701ae15596c36194684453fef9ee075e.1471496833.git.janani.rvchndrn@gmail.com>
	 <20160818063239.GO2356@ZenIV.linux.org.uk>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@ZenIV.linux.org.uk>, Janani Ravichandran <janani.rvchndrn@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, vdavydov@virtuozzo.com, mhocko@suse.com, vbabka@suse.cz, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, bywxiaobai@163.com

On Thu, 2016-08-18 at 07:32 +0100, Al Viro wrote:
> On Thu, Aug 18, 2016 at 02:09:31AM -0400, Janani Ravichandran wrote:
>=20
> > =C2=A0static LIST_HEAD(super_blocks);
> > @@ -64,6 +65,7 @@ static unsigned long super_cache_scan(struct
> > shrinker *shrink,
> > =C2=A0	long	inodes;
> > =C2=A0
> > =C2=A0	sb =3D container_of(shrink, struct super_block, s_shrink);
> > +	trace_mm_shrinker_callback(shrink, sb->s_type->name);
>=20
> IOW, we are (should that patch be accepted) obliged to keep the
> function in
> question and the guts of struct shrinker indefinitely.
>=20
> NAK.=C2=A0=C2=A0Keep your debugging patches in your tree and maintain the=
m
> yourself.
> And if a change in the kernel data structures breaks them (and your
> userland
> code relying on those), it's your problem.
>=20
> Tracepoints are very nice for local debugging/data collection/etc.
> patches.
>=20

The issue is that production systems often need
debugging, and when there are performance issues
we need some way to gather all the necessary info,
without rebooting the production system into a
special debug kernel.

This is not an ABI that userspace can rely on,
and should not be considered as such. Any
performance tracing/debugging scripts can be
easily changed to match the kernel running on
the system in question.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
