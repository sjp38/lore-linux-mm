Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f45.google.com (mail-yh0-f45.google.com [209.85.213.45])
	by kanga.kvack.org (Postfix) with ESMTP id 5A2416B0069
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 03:04:25 -0500 (EST)
Received: by mail-yh0-f45.google.com with SMTP id v1so3591724yhn.18
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 00:04:25 -0800 (PST)
Received: from mail-pb0-x231.google.com (mail-pb0-x231.google.com [2607:f8b0:400e:c01::231])
        by mx.google.com with ESMTPS id 41si13061996yhf.77.2013.12.10.00.04.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 10 Dec 2013 00:04:24 -0800 (PST)
Received: by mail-pb0-f49.google.com with SMTP id jt11so7123350pbb.36
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 00:04:23 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <efacba489a23b3a87321a02828ed1a5094e5c490.1386571280.git.vdavydov@parallels.com>
References: <cover.1386571280.git.vdavydov@parallels.com>
	<efacba489a23b3a87321a02828ed1a5094e5c490.1386571280.git.vdavydov@parallels.com>
Date: Tue, 10 Dec 2013 12:04:23 +0400
Message-ID: <CAA6-i6oESDwswkmz9hUT7=v8AE4z4GeTqwqrMzxOyTUtanLB-A@mail.gmail.com>
Subject: Re: [PATCH v13 04/16] memcg: move memcg_caches_array_size() function
From: Glauber Costa <glommer@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: dchinner@redhat.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, Glauber Costa <glommer@openvz.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Mon, Dec 9, 2013 at 12:05 PM, Vladimir Davydov
<vdavydov@parallels.com> wrote:
> I need to move this up a bit, and I am doing in a separate patch just to
> reduce churn in the patch that needs it.
>
> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Reviewed-by: Glauber Costa <glommer@openvz.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
