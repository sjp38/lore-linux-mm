Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id C75468E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 14:19:32 -0500 (EST)
Received: by mail-lj1-f199.google.com with SMTP id t22-v6so3998512lji.14
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 11:19:32 -0800 (PST)
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id s191si64615255lfs.9.2019.01.11.11.19.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Jan 2019 11:19:31 -0800 (PST)
Subject: Re: [PATCH 3/3] mm/vmalloc: pass VM_USERMAP flags directly to
 __vmalloc_node_range()
References: <20190103145954.16942-1-rpenyaev@suse.de>
 <20190103145954.16942-4-rpenyaev@suse.de>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <75680183-6e15-0487-c758-d1ce5fba27bc@virtuozzo.com>
Date: Fri, 11 Jan 2019 22:19:52 +0300
MIME-Version: 1.0
In-Reply-To: <20190103145954.16942-4-rpenyaev@suse.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Penyaev <rpenyaev@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Joe Perches <joe@perches.com>, "Luis R. Rodriguez" <mcgrof@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 1/3/19 5:59 PM, Roman Penyaev wrote:
> vmalloc_user*() calls differ from normal vmalloc() only in that they
> set VM_USERMAP flags for the area.  During the whole history of
> vmalloc.c changes now it is possible simply to pass VM_USERMAP flags
> directly to __vmalloc_node_range() call instead of finding the area
> (which obviously takes time) after the allocation.
> 
> Signed-off-by: Roman Penyaev <rpenyaev@suse.de>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Cc: Joe Perches <joe@perches.com>
> Cc: "Luis R. Rodriguez" <mcgrof@kernel.org>
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org

Acked-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
