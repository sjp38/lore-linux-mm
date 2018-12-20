Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0CE0A8E0001
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 16:00:21 -0500 (EST)
Received: by mail-yb1-f198.google.com with SMTP id t2-v6so1917406ybg.15
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 13:00:21 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id w12-v6si13009167ybk.137.2018.12.20.13.00.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Dec 2018 13:00:20 -0800 (PST)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [PATCH v3] mm/page_owner: fix for deferred struct page init
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <20181220203156.43441-1-cai@lca.pw>
Date: Thu, 20 Dec 2018 14:00:10 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <E084FF0A-88CD-4E61-88F2-7D542D67DDF1@oracle.com>
References: <20181220185031.43146-1-cai@lca.pw>
 <20181220203156.43441-1-cai@lca.pw>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qian Cai <cai@lca.pw>
Cc: akpm@linux-foundation.org, mhocko@suse.com, Pavel.Tatashin@microsoft.com, mingo@kernel.org, hpa@zytor.com, mgorman@techsingularity.net, iamjoonsoo.kim@lge.com, yang.shi@linaro.org, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org



> On Dec 20, 2018, at 1:31 PM, Qian Cai <cai@lca.pw> wrote:
>=20
> diff --git a/mm/page_ext.c b/mm/page_ext.c
> index ae44f7adbe07..d76fd51e312a 100644
> --- a/mm/page_ext.c
> +++ b/mm/page_ext.c
> @@ -399,9 +399,8 @@ void __init page_ext_init(void)
> 			 * -------------pfn-------------->
> 			 * N0 | N1 | N2 | N0 | N1 | N2|....
> 			 *
> -			 * Take into account DEFERRED_STRUCT_PAGE_INIT.
> 			 */
> -			if (early_pfn_to_nid(pfn) !=3D nid)
> +			if (pfn_to_nid(pfn) !=3D nid)
> 				continue;
> 			if (init_section_page_ext(pfn, nid))
> 				goto oom;
> --=20
> 2.17.2 (Apple Git-113)
>=20

Is there any danger in the fact that in the CONFIG_NUMA case in mmzone.h =
(around line 1261), pfn_to_nid() calls page_to_nid(), possibly causing =
the same issue seen in v2?
