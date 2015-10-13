Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 2585D6B0253
	for <linux-mm@kvack.org>; Mon, 12 Oct 2015 21:43:17 -0400 (EDT)
Received: by igbni9 with SMTP id ni9so48763661igb.1
        for <linux-mm@kvack.org>; Mon, 12 Oct 2015 18:43:17 -0700 (PDT)
Received: from mail-pa0-x244.google.com (mail-pa0-x244.google.com. [2607:f8b0:400e:c03::244])
        by mx.google.com with ESMTPS id b80si822631ioe.177.2015.10.12.18.43.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Oct 2015 18:43:16 -0700 (PDT)
Received: by padew5 with SMTP id ew5so420863pad.0
        for <linux-mm@kvack.org>; Mon, 12 Oct 2015 18:43:16 -0700 (PDT)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.0 \(3094\))
Subject: Re: [RFC] mm: fix a BUG, the page is allocated 2 times
From: yalin wang <yalin.wang2010@gmail.com>
In-Reply-To: <20151012135250.GA3625@techsingularity.net>
Date: Tue, 13 Oct 2015 09:43:11 +0800
Content-Transfer-Encoding: quoted-printable
Message-Id: <71CD787F-57A8-4F95-9D16-BA73E1F87FE1@gmail.com>
References: <1444617606-8685-1-git-send-email-yalin.wang2010@gmail.com> <20151012135250.GA3625@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: akpm@linux-foundation.org, vbabka@suse.cz, mhocko@suse.com, rientjes@google.com, js1304@gmail.com, kirill.shutemov@linux.intel.com, hannes@cmpxchg.org, alexander.h.duyck@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org


> On Oct 12, 2015, at 21:52, Mel Gorman <mgorman@techsingularity.net> =
wrote:
>=20
> There is a redundant check and a memory leak introduced by a patch in
> mmotm. This patch removes an unlikely(order) check as we are sure =
order
> is not zero at the time. It also checks if a page is already allocated
> to avoid a memory leak.
>=20
> This is a fix to the mmotm patch
> =
mm-page_alloc-reserve-pageblocks-for-high-order-atomic-allocations-on-dema=
nd.patch
>=20
> Signed-off-by: yalin wang <yalin.wang2010@gmail.com>
> Acked-by: Mel Gorman <mgorman@techsingularity.net>
no problem,
i have send the patch again using your change log .

Thanks=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
