Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 33D7E6B02C8
	for <linux-mm@kvack.org>; Thu, 16 Aug 2018 13:45:46 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id w8-v6so5135739qkf.8
        for <linux-mm@kvack.org>; Thu, 16 Aug 2018 10:45:46 -0700 (PDT)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0135.outbound.protection.outlook.com. [104.47.33.135])
        by mx.google.com with ESMTPS id t68-v6si1279743qkl.70.2018.08.16.10.45.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 16 Aug 2018 10:45:45 -0700 (PDT)
From: Pasha Tatashin <Pavel.Tatashin@microsoft.com>
Subject: Re: [PATCH v3 1/4] mm/memory-hotplug: Drop unused args from
 remove_memory_section
Date: Thu, 16 Aug 2018 17:45:43 +0000
Message-ID: <20180816174543.e6puawtdomoadnrd@xakep.localdomain>
References: <20180815144219.6014-1-osalvador@techadventures.net>
 <20180815144219.6014-2-osalvador@techadventures.net>
In-Reply-To: <20180815144219.6014-2-osalvador@techadventures.net>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <14461EB7149D29409BA6145B64D908DE@namprd21.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@techadventures.net>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mhocko@suse.com" <mhocko@suse.com>, "vbabka@suse.cz" <vbabka@suse.cz>, "dan.j.williams@intel.com" <dan.j.williams@intel.com>, "yasu.isimatu@gmail.com" <yasu.isimatu@gmail.com>, "jonathan.cameron@huawei.com" <jonathan.cameron@huawei.com>, "david@redhat.com" <david@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Oscar Salvador <osalvador@suse.de>

On 18-08-15 16:42:16, Oscar Salvador wrote:
> From: Oscar Salvador <osalvador@suse.de>
>=20
> unregister_memory_section() calls remove_memory_section()
> with three arguments:
>=20
> * node_id
> * section
> * phys_device
>=20
> Neither node_id nor phys_device are used.
> Let us drop them from the function.

Looks good:
Reviewed-by: Pavel Tatashin <pavel.tatashin@microsoft.com>

>=20
> Signed-off-by: Oscar Salvador <osalvador@suse.de>
> Reviewed-by: David Hildenbrand <david@redhat.com>
> Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
> ---
>  drivers/base/memory.c | 5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)
>=20
> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> index c8a1cb0b6136..2c622a9a7490 100644
> --- a/drivers/base/memory.c
> +++ b/drivers/base/memory.c
> @@ -752,8 +752,7 @@ unregister_memory(struct memory_block *memory)
>  	device_unregister(&memory->dev);
>  }
> =20
> -static int remove_memory_section(unsigned long node_id,
> -			       struct mem_section *section, int phys_device)
> +static int remove_memory_section(struct mem_section *section)
>  {
>  	struct memory_block *mem;
> =20
> @@ -785,7 +784,7 @@ int unregister_memory_section(struct mem_section *sec=
tion)
>  	if (!present_section(section))
>  		return -EINVAL;
> =20
> -	return remove_memory_section(0, section, 0);
> +	return remove_memory_section(section);
>  }
>  #endif /* CONFIG_MEMORY_HOTREMOVE */
> =20
> --=20
> 2.13.6
> =
