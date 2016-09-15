Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8E2C46B0038
	for <linux-mm@kvack.org>; Thu, 15 Sep 2016 14:51:29 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 1so36820438wmz.2
        for <linux-mm@kvack.org>; Thu, 15 Sep 2016 11:51:29 -0700 (PDT)
Received: from mail-lf0-x242.google.com (mail-lf0-x242.google.com. [2a00:1450:4010:c07::242])
        by mx.google.com with ESMTPS id f11si2860615lfb.309.2016.09.15.11.51.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Sep 2016 11:51:28 -0700 (PDT)
Received: by mail-lf0-x242.google.com with SMTP id s64so3845535lfs.2
        for <linux-mm@kvack.org>; Thu, 15 Sep 2016 11:51:27 -0700 (PDT)
From: Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>
Reply-To: arekm@maven.pl
Subject: Re: [PATCH 0/4] reintroduce compaction feedback for OOM decisions
Date: Thu, 15 Sep 2016 20:51:25 +0200
References: <20160906135258.18335-1-vbabka@suse.cz>
In-Reply-To: <20160906135258.18335-1-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Message-Id: <201609152051.25268.a.miskiewicz@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Olaf Hering <olaf@aepfle.de>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, Rik van Riel <riel@redhat.com>

On Tuesday 06 of September 2016, Vlastimil Babka wrote:
> After several people reported OOM's for order-2 allocations in 4.7 due to
> Michal Hocko's OOM rework, he reverted the part that considered compaction
> feedback [1] in the decisions to retry reclaim/compaction. This was to
> provide a fix quickly for 4.8 rc and 4.7 stable series, while mmotm had an
> almost complete solution that instead improved compaction reliability.
>=20
> This series completes the mmotm solution and reintroduces the compaction
> feedback into OOM decisions. The first two patches restore the state of
> mmotm before the temporary solution was merged, the last patch should be
> the missing piece for reliability. The third patch restricts the hardened
> compaction to non-costly orders, since costly orders don't result in OOMs
> in the first place.
>=20
> Some preliminary testing suggested that this approach should work, but I
> would like to ask all who experienced the regression to please retest
> this. You will need to apply this series on top of tag
> mmotm-2016-08-31-16-06 from the mmotm git tree [2]. Thanks in advance!

My "rm -rf copyX; cp -al org copyX" test x10 in parallel worked without any=
=20
OOM.


=2D-=20
Arkadiusz Mi=C5=9Bkiewicz, arekm / ( maven.pl | pld-linux.org )

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
