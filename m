Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 300176B0271
	for <linux-mm@kvack.org>; Thu,  1 Nov 2018 20:42:04 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id b9-v6so285985yba.17
        for <linux-mm@kvack.org>; Thu, 01 Nov 2018 17:42:04 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id i3-v6si19251536ywd.372.2018.11.01.17.42.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Nov 2018 17:42:03 -0700 (PDT)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [PATCH v4] mm/page_owner: clamp read count to PAGE_SIZE
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <20181101144723.3ddc1fa1ab7f81184bc2fdb8@linux-foundation.org>
Date: Thu, 1 Nov 2018 18:41:33 -0600
Content-Transfer-Encoding: quoted-printable
Message-Id: <FD1082D9-916E-47A4-95D3-59F308AD6D55@oracle.com>
References: <1541091607-27402-1-git-send-email-miles.chen@mediatek.com>
 <20181101144723.3ddc1fa1ab7f81184bc2fdb8@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: miles.chen@mediatek.com, Michal Hocko <mhocko@suse.com>, Joe Perches <joe@perches.com>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mediatek@lists.infradead.org, wsd_upstream@mediatek.com, Michal Hocko <mhocko@kernel.org>



> On Nov 1, 2018, at 3:47 PM, Andrew Morton <akpm@linux-foundation.org> =
wrote:
>=20
> -	count =3D count > PAGE_SIZE ? PAGE_SIZE : count;
> +	count =3D min_t(size_t, count, PAGE_SIZE);
> 	kbuf =3D kmalloc(count, GFP_KERNEL);
> 	if (!kbuf)
> 		return -ENOMEM;

Is the use of min_t vs. the C conditional mostly to be more =
self-documenting?

The compiler-generated assembly between the two versions seems mostly a =
wash.

    William Kucharski=
