Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 269086B0003
	for <linux-mm@kvack.org>; Thu,  1 Nov 2018 22:45:49 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id u8-v6so451303wrn.17
        for <linux-mm@kvack.org>; Thu, 01 Nov 2018 19:45:49 -0700 (PDT)
Received: from APC01-PU1-obe.outbound.protection.outlook.com (mail-pu1apc01on0101.outbound.protection.outlook.com. [104.47.126.101])
        by mx.google.com with ESMTPS id k126-v6si10963005wmd.122.2018.11.01.19.45.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 01 Nov 2018 19:45:47 -0700 (PDT)
From: Dexuan Cui <decui@microsoft.com>
Subject: RE: Will the recent memory leak fixes be backported to longterm
 kernels?
Date: Fri, 2 Nov 2018 02:45:42 +0000
Message-ID: 
 <PU1P153MB0169FE681EF81BCE81B005A1BFCF0@PU1P153MB0169.APCP153.PROD.OUTLOOK.COM>
References: 
 <PU1P153MB0169CB6382E0F047579D111DBFCF0@PU1P153MB0169.APCP153.PROD.OUTLOOK.COM>
 <20181102005816.GA10297@tower.DHCP.thefacebook.com>
In-Reply-To: <20181102005816.GA10297@tower.DHCP.thefacebook.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Kernel Team <Kernel-team@fb.com>, Shakeel Butt <shakeelb@google.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Rik van Riel <riel@surriel.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Matthew Wilcox <willy@infradead.org>, "Stable@vger.kernel.org" <Stable@vger.kernel.org>

> From: Roman Gushchin <guro@fb.com>
> Sent: Thursday, November 1, 2018 17:58
>=20
> On Fri, Nov 02, 2018 at 12:16:02AM +0000, Dexuan Cui wrote:
> Hello, Dexuan!
>=20
> A couple of issues has been revealed recently, here are fixes
> (hashes are from the next tree):
>=20
> 5f4b04528b5f mm: don't reclaim inodes with many attached pages
> 5a03b371ad6a mm: handle no memcg case in memcg_kmem_charge()
> properly
>=20
> These two patches should be added to the serie.

Thanks for the new info!
=20
> Re stable backporting, I'd really wait for some time. Memory reclaim is a
> quite complex and fragile area, so even if patches are correct by themsel=
ves,
> they can easily cause a regression by revealing some other issues (as it =
was
> with the inode reclaim case).

I totally agree. I'm now just wondering if there is any temporary workaroun=
d,
even if that means we have to run the kernel with some features disabled or
with a suboptimal performance?

Thanks!
--Dexuan
