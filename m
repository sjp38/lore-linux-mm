Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 411D46B033F
	for <linux-mm@kvack.org>; Thu, 16 Aug 2018 14:59:34 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id bb5-v6so3292011plb.13
        for <linux-mm@kvack.org>; Thu, 16 Aug 2018 11:59:34 -0700 (PDT)
Received: from NAM03-CO1-obe.outbound.protection.outlook.com (mail-co1nam03on0101.outbound.protection.outlook.com. [104.47.40.101])
        by mx.google.com with ESMTPS id y67-v6si87823pfa.47.2018.08.16.11.59.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 16 Aug 2018 11:59:33 -0700 (PDT)
From: Pasha Tatashin <Pavel.Tatashin@microsoft.com>
Subject: Re: [PATCH v3 4/4] mm/memory_hotplug: Drop node_online check in
 unregister_mem_sect_under_nodes
Date: Thu, 16 Aug 2018 18:59:31 +0000
Message-ID: <20180816185930.tfg2rzjnh34lmuxa@xakep.localdomain>
References: <20180815144219.6014-1-osalvador@techadventures.net>
 <20180815144219.6014-5-osalvador@techadventures.net>
In-Reply-To: <20180815144219.6014-5-osalvador@techadventures.net>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <E026F4C5C651CE45ABA9F717F027A8C3@namprd21.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@techadventures.net>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mhocko@suse.com" <mhocko@suse.com>, "vbabka@suse.cz" <vbabka@suse.cz>, "dan.j.williams@intel.com" <dan.j.williams@intel.com>, "yasu.isimatu@gmail.com" <yasu.isimatu@gmail.com>, "jonathan.cameron@huawei.com" <jonathan.cameron@huawei.com>, "david@redhat.com" <david@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Oscar Salvador <osalvador@suse.de>

On 18-08-15 16:42:19, Oscar Salvador wrote:
> From: Oscar Salvador <osalvador@suse.de>
>=20
> We are getting the nid from the pages that are not yet removed,
> but a node can only be offline when its memory/cpu's have been removed.
> Therefore, we know that the node is still online.

Reviewed-by: Pavel Tatashin <pavel.tatashin@microsoft.com>

>=20
> Signed-off-by: Oscar Salvador <osalvador@suse.de>
> ---
>  drivers/base/node.c | 2 --
>  1 file changed, 2 deletions(-)
>=20
> diff --git a/drivers/base/node.c b/drivers/base/node.c
> index 81b27b5b1f15..b23769e4fcbb 100644
> --- a/drivers/base/node.c
> +++ b/drivers/base/node.c
> @@ -465,8 +465,6 @@ void unregister_mem_sect_under_nodes(struct memory_bl=
ock *mem_blk,
> =20
>  		if (nid < 0)
>  			continue;
> -		if (!node_online(nid))
> -			continue;
>  		/*
>  		 * It is possible that NODEMASK_ALLOC fails due to memory
>  		 * pressure.
> --=20
> 2.13.6
> =
