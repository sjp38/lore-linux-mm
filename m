Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5B2A96B02C7
	for <linux-mm@kvack.org>; Thu, 16 Aug 2018 13:20:31 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id 90-v6so3108376pla.18
        for <linux-mm@kvack.org>; Thu, 16 Aug 2018 10:20:31 -0700 (PDT)
Received: from NAM05-CO1-obe.outbound.protection.outlook.com (mail-eopbgr720098.outbound.protection.outlook.com. [40.107.72.98])
        by mx.google.com with ESMTPS id e11-v6si22710526pga.150.2018.08.16.10.20.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 16 Aug 2018 10:20:29 -0700 (PDT)
From: Pasha Tatashin <Pavel.Tatashin@microsoft.com>
Subject: Re: [PATCH v2 3/4] mm/memory_hotplug: Make
 register_mem_sect_under_node a cb of walk_memory_range
Date: Thu, 16 Aug 2018 17:20:27 +0000
Message-ID: <20180816172026.s2v3ytqnkiboo72s@xakep.localdomain>
References: <20180622111839.10071-1-osalvador@techadventures.net>
 <20180622111839.10071-4-osalvador@techadventures.net>
In-Reply-To: <20180622111839.10071-4-osalvador@techadventures.net>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <C4F53580C4051E42884241A129D12C36@namprd21.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "osalvador@techadventures.net" <osalvador@techadventures.net>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mhocko@suse.com" <mhocko@suse.com>, "vbabka@suse.cz" <vbabka@suse.cz>, Pasha Tatashin <Pavel.Tatashin@microsoft.com>, "Jonathan.Cameron@huawei.com" <Jonathan.Cameron@huawei.com>, "arbab@linux.vnet.ibm.com" <arbab@linux.vnet.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Oscar Salvador <osalvador@suse.de>

On 18-06-22 13:18:38, osalvador@techadventures.net wrote:
> From: Oscar Salvador <osalvador@suse.de>
>=20
> link_mem_sections() and walk_memory_range() share most of the code,
> so we can use convert link_mem_sections() into a dummy function that call=
s
> walk_memory_range() with a callback to register_mem_sect_under_node().
>=20
> This patch converts register_mem_sect_under_node() in order to
> match a walk_memory_range's callback, getting rid of the
> check_nid argument and checking instead if the system is still
> boothing, since we only have to check for the nid if the system
> is in such state.
>=20
> Signed-off-by: Oscar Salvador <osalvador@suse.de>
> Suggested-by: Pavel Tatashin <pasha.tatashin@oracle.com>

Reviewed-by: Pavel Tatashin <pavel.tatashin@microsoft.com>=
