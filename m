Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id D28796B026E
	for <linux-mm@kvack.org>; Thu,  1 Nov 2018 20:16:07 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id y12-v6so236026ybg.23
        for <linux-mm@kvack.org>; Thu, 01 Nov 2018 17:16:07 -0700 (PDT)
Received: from APC01-PU1-obe.outbound.protection.outlook.com (mail-pu1apc01on0094.outbound.protection.outlook.com. [104.47.126.94])
        by mx.google.com with ESMTPS id n204-v6si12487684ybb.311.2018.11.01.17.16.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 01 Nov 2018 17:16:06 -0700 (PDT)
From: Dexuan Cui <decui@microsoft.com>
Subject: Will the recent memory leak fixes be backported to longterm kernels?
Date: Fri, 2 Nov 2018 00:16:02 +0000
Message-ID: 
 <PU1P153MB0169CB6382E0F047579D111DBFCF0@PU1P153MB0169.APCP153.PROD.OUTLOOK.COM>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kernel-team@fb.com" <kernel-team@fb.com>, Shakeel Butt <shakeelb@google.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Rik van Riel <riel@surriel.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Matthew Wilcox <willy@infradead.org>
Cc: "Stable@vger.kernel.org" <Stable@vger.kernel.org>

Hi all,
When debugging a memory leak issue (https://github.com/coreos/bugs/issues/2=
516)
with v4.14.11-coreos, we noticed the same issue may have been fixed recentl=
y by
Roman in the latest mainline (i.e. Linus's master branch) according to comm=
ent #7 of=20
https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1792349, which lists t=
hese
patches (I'm not sure if the 5-patch list is complete):

010cb21d4ede math64: prevent double calculation of DIV64_U64_ROUND_UP() arg=
uments
f77d7a05670d mm: don't miss the last page because of round-off error
d18bf0af683e mm: drain memcg stocks on css offlining
71cd51b2e1ca mm: rework memcg kernel stack accounting
f3a2fccbce15 mm: slowly shrink slabs with a relatively small number of obje=
cts

Obviously at least some of the fixes are also needed in the longterm kernel=
s like v4.14.y,
but none of the 5 patches has the "Cc: stable@vger.kernel.org" tag? I'm won=
dering if
these patches will be backported to the longterm kernels. BTW, the patches =
are not
in v4.19, but I suppose they will be in v4.19.1-rc1?

Thanks,
-- Dexuan
