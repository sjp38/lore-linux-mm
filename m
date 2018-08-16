Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 884066B02D8
	for <linux-mm@kvack.org>; Thu, 16 Aug 2018 13:53:28 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id u13-v6so2403110pfm.8
        for <linux-mm@kvack.org>; Thu, 16 Aug 2018 10:53:28 -0700 (PDT)
Received: from NAM04-CO1-obe.outbound.protection.outlook.com (mail-eopbgr690130.outbound.protection.outlook.com. [40.107.69.130])
        by mx.google.com with ESMTPS id e12-v6si23333634pls.70.2018.08.16.10.53.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 16 Aug 2018 10:53:27 -0700 (PDT)
From: Pasha Tatashin <Pavel.Tatashin@microsoft.com>
Subject: Re: [PATCH v3 2/4] mm/memory_hotplug: Drop mem_blk check from
 unregister_mem_sect_under_nodes
Date: Thu, 16 Aug 2018 17:53:25 +0000
Message-ID: <20180816175325.xd4qmlauh65qszsk@xakep.localdomain>
References: <20180815144219.6014-1-osalvador@techadventures.net>
 <20180815144219.6014-3-osalvador@techadventures.net>
In-Reply-To: <20180815144219.6014-3-osalvador@techadventures.net>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <9F1C39793C0BC942BFE08BC4D9CCDD1A@namprd21.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@techadventures.net>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mhocko@suse.com" <mhocko@suse.com>, "vbabka@suse.cz" <vbabka@suse.cz>, "dan.j.williams@intel.com" <dan.j.williams@intel.com>, "yasu.isimatu@gmail.com" <yasu.isimatu@gmail.com>, "jonathan.cameron@huawei.com" <jonathan.cameron@huawei.com>, "david@redhat.com" <david@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Oscar Salvador <osalvador@suse.de>

On 18-08-15 16:42:17, Oscar Salvador wrote:
> From: Oscar Salvador <osalvador@suse.de>
>=20
> Before calling to unregister_mem_sect_under_nodes(),
> remove_memory_section() already checks if we got a valid memory_block.
>=20
> No need to check that again in unregister_mem_sect_under_nodes().
>=20
> If more functions start using unregister_mem_sect_under_nodes() in the
> future, we can always place a WARN_ON to catch null mem_blk's so we can
> safely back off.
>=20
> For now, let us keep the check in remove_memory_section() since it is the
> only function that uses it.
>=20
> Signed-off-by: Oscar Salvador <osalvador@suse.de>
> Reviewed-by: Andrew Morton <akpm@linux-foundation.org>

Reviewed-by: Pavel Tatashin <pavel.tatashin@microsoft.com>

> ---
>  drivers/base/node.c | 4 ----
>  1 file changed, 4 deletions(-)
>=20
> diff --git a/drivers/base/node.c b/drivers/base/node.c
> index 1ac4c36e13bb..dd3bdab230b2 100644
> --- a/drivers/base/node.c
> +++ b/drivers/base/node.c
> @@ -455,10 +455,6 @@ int unregister_mem_sect_under_nodes(struct memory_bl=
ock *mem_blk,
>  	NODEMASK_ALLOC(nodemask_t, unlinked_nodes, GFP_KERNEL);
>  	unsigned long pfn, sect_start_pfn, sect_end_pfn;
> =20
> -	if (!mem_blk) {
> -		NODEMASK_FREE(unlinked_nodes);
> -		return -EFAULT;
> -	}
>  	if (!unlinked_nodes)
>  		return -ENOMEM;
>  	nodes_clear(*unlinked_nodes);
> --=20
> 2.13.6
> =
