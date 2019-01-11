Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6B1618E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 14:18:56 -0500 (EST)
Received: by mail-lj1-f197.google.com with SMTP id g12-v6so4026707lji.3
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 11:18:56 -0800 (PST)
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id m20si57990147lfb.58.2019.01.11.11.18.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Jan 2019 11:18:54 -0800 (PST)
Subject: Re: [PATCH 1/3] mm/vmalloc: fix size check for
 remap_vmalloc_range_partial()
References: <20190103145954.16942-1-rpenyaev@suse.de>
 <20190103145954.16942-2-rpenyaev@suse.de>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <873d9ee8-9cee-b6f1-ca2c-f4da2d2ddfc0@virtuozzo.com>
Date: Fri, 11 Jan 2019 22:19:12 +0300
MIME-Version: 1.0
In-Reply-To: <20190103145954.16942-2-rpenyaev@suse.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Penyaev <rpenyaev@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Joe Perches <joe@perches.com>, "Luis R. Rodriguez" <mcgrof@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org



On 1/3/19 5:59 PM, Roman Penyaev wrote:
> area->size can include adjacent guard page but get_vm_area_size()
> returns actual size of the area.
> 
> This fixes possible kernel crash when userspace tries to map area
> on 1 page bigger: size check passes but the following vmalloc_to_page()
> returns NULL on last guard (non-existing) page.
> 
> Signed-off-by: Roman Penyaev <rpenyaev@suse.de>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Cc: Joe Perches <joe@perches.com>
> Cc: "Luis R. Rodriguez" <mcgrof@kernel.org>
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org
> Cc: stable@vger.kernel.org
> ---

Fixes: e69e9d4aee71 ("vmalloc: introduce remap_vmalloc_range_partial")
Acked-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
