Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 8E1D66B006E
	for <linux-mm@kvack.org>; Tue, 21 Oct 2014 02:31:30 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id y13so678618pdi.5
        for <linux-mm@kvack.org>; Mon, 20 Oct 2014 23:31:30 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id wu4si10006558pbc.19.2014.10.20.23.31.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Oct 2014 23:31:29 -0700 (PDT)
Date: Tue, 21 Oct 2014 10:31:19 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -mm] memcg: remove activate_kmem_mutex
Message-ID: <20141021063119.GM16496@esperanza>
References: <1413817889-13915-1-git-send-email-vdavydov@parallels.com>
 <20141020185306.GB505@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20141020185306.GB505@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Oct 20, 2014 at 08:53:06PM +0200, Michal Hocko wrote:
> On Mon 20-10-14 19:11:29, Vladimir Davydov wrote:
> > The activate_kmem_mutex is used to serialize memcg.kmem.limit updates,
> > but we already serialize them with memcg_limit_mutex so let's remove the
> > former.
> > 
> > Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
> 
> Is this the case since bd67314586a3 (memcg, slab: simplify
> synchronization scheme)?

No, it's since Johannes' lockless page counters patch where we have the
memcg_limit_mutex introduced to synchronize concurrent limit updates (mm
commit dc1815408849 "mm: memcontrol: lockless page counters").

Thanks,
Vladimir

> Anyway Looks good to me.
> Acked-by: Michal Hocko <mhocko@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
