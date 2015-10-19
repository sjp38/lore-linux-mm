Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 9941E82F67
	for <linux-mm@kvack.org>; Mon, 19 Oct 2015 04:08:26 -0400 (EDT)
Received: by wicll6 with SMTP id ll6so84061792wic.0
        for <linux-mm@kvack.org>; Mon, 19 Oct 2015 01:08:26 -0700 (PDT)
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com. [209.85.212.179])
        by mx.google.com with ESMTPS id cz1si39597384wjc.191.2015.10.19.01.08.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Oct 2015 01:08:25 -0700 (PDT)
Received: by wicfx6 with SMTP id fx6so38168682wic.1
        for <linux-mm@kvack.org>; Mon, 19 Oct 2015 01:08:24 -0700 (PDT)
Date: Mon, 19 Oct 2015 10:08:23 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/3] memcg: simplify and inline __mem_cgroup_from_kmem
Message-ID: <20151019080822.GB11998@dhcp22.suse.cz>
References: <9be67d8528d316ce90d78980bce9ed76b00ffd22.1443996201.git.vdavydov@virtuozzo.com>
 <517ab1701f4b53be8bfd6691a1499598efb358e7.1443996201.git.vdavydov@virtuozzo.com>
 <20151016131726.GA602@node.shutemov.name>
 <20151016135106.GJ11309@esperanza>
 <alpine.LSU.2.11.1510161458280.26747@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1510161458280.26747@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Arnd Bergmann <arnd@arndb.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 16-10-15 15:12:23, Hugh Dickins wrote:
[...]
> Are you expecting to use mem_cgroup_from_kmem() from other places
> in future?  Seems possible; but at present it's called from only
> one place, and (given how memcontrol.h has somehow managed to avoid
> including mm.h all these years), I thought it would be nice to avoid
> it for just this; and fixed my build with the patch below last night.
> Whatever you all think best: just wanted to point out an alternative.

Yes, this is better.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
