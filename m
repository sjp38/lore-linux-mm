Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id BB2476B0271
	for <linux-mm@kvack.org>; Thu,  1 Nov 2018 20:59:00 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id d17-v6so414087edv.4
        for <linux-mm@kvack.org>; Thu, 01 Nov 2018 17:59:00 -0700 (PDT)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id u5-v6si10852134edc.141.2018.11.01.17.58.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Nov 2018 17:58:59 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: Re: Will the recent memory leak fixes be backported to longterm
 kernels?
Date: Fri, 2 Nov 2018 00:58:23 +0000
Message-ID: <20181102005816.GA10297@tower.DHCP.thefacebook.com>
References: <PU1P153MB0169CB6382E0F047579D111DBFCF0@PU1P153MB0169.APCP153.PROD.OUTLOOK.COM>
In-Reply-To: <PU1P153MB0169CB6382E0F047579D111DBFCF0@PU1P153MB0169.APCP153.PROD.OUTLOOK.COM>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <7847F6CBC0D60A4B9006A68198DF7FBF@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dexuan Cui <decui@microsoft.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Kernel Team <Kernel-team@fb.com>, Shakeel
 Butt <shakeelb@google.com>, Michal Hocko <mhocko@kernel.org>, Johannes
 Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Rik van Riel <riel@surriel.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Matthew Wilcox <willy@infradead.org>, "Stable@vger.kernel.org" <Stable@vger.kernel.org>

On Fri, Nov 02, 2018 at 12:16:02AM +0000, Dexuan Cui wrote:
> Hi all,
> When debugging a memory leak issue (https://github.com/coreos/bugs/issues=
/2516)
> with v4.14.11-coreos, we noticed the same issue may have been fixed recen=
tly by
> Roman in the latest mainline (i.e. Linus's master branch) according to co=
mment #7 of=20
> https://urldefense.proofpoint.com/v2/url?u=3Dhttps-3A__bugs.launchpad.net=
_ubuntu_-2Bsource_linux_-2Bbug_1792349&d=3DDwIFAg&c=3D5VD0RTtNlTh3ycd41b3MU=
w&r=3Di6WobKxbeG3slzHSIOxTVtYIJw7qjCE6S0spDTKL-J4&m=3DmrT9jcrhFvVxDpVBlxihJ=
g6S6U91rlevOJby7y1YynE&s=3D1eHLVA-oQGqMd2ujRPU8kZMbkShOuIDD5CUgpM1IzGI&e=3D=
, which lists these
> patches (I'm not sure if the 5-patch list is complete):
>=20
> 010cb21d4ede math64: prevent double calculation of DIV64_U64_ROUND_UP() a=
rguments
> f77d7a05670d mm: don't miss the last page because of round-off error
> d18bf0af683e mm: drain memcg stocks on css offlining
> 71cd51b2e1ca mm: rework memcg kernel stack accounting
> f3a2fccbce15 mm: slowly shrink slabs with a relatively small number of ob=
jects
>=20
> Obviously at least some of the fixes are also needed in the longterm kern=
els like v4.14.y,
> but none of the 5 patches has the "Cc: stable@vger.kernel.org" tag? I'm w=
ondering if
> these patches will be backported to the longterm kernels. BTW, the patche=
s are not
> in v4.19, but I suppose they will be in v4.19.1-rc1?

Hello, Dexuan!

A couple of issues has been revealed recently, here are fixes
(hashes are from the next tree):

5f4b04528b5f mm: don't reclaim inodes with many attached pages
5a03b371ad6a mm: handle no memcg case in memcg_kmem_charge() properly

These two patches should be added to the serie.

Re stable backporting, I'd really wait for some time. Memory reclaim is a
quite complex and fragile area, so even if patches are correct by themselve=
s,
they can easily cause a regression by revealing some other issues (as it wa=
s
with the inode reclaim case).

Thanks!
