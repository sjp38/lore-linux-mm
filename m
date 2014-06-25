Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f181.google.com (mail-we0-f181.google.com [74.125.82.181])
	by kanga.kvack.org (Postfix) with ESMTP id EF0006B0036
	for <linux-mm@kvack.org>; Wed, 25 Jun 2014 00:02:06 -0400 (EDT)
Received: by mail-we0-f181.google.com with SMTP id q59so1351762wes.40
        for <linux-mm@kvack.org>; Tue, 24 Jun 2014 21:02:06 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id r8si4489385wia.83.2014.06.24.21.02.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 24 Jun 2014 21:02:05 -0700 (PDT)
Date: Wed, 25 Jun 2014 00:01:59 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH -mm 2/3] page-cgroup: get rid of NR_PCG_FLAGS
Message-ID: <20140625040159.GQ7331@cmpxchg.org>
References: <9f5abf8dcb07fe5462f12f81867f199c22e883d3.1403626729.git.vdavydov@parallels.com>
 <26252c1699103f7efe51b224dd61bdb74e31f255.1403626729.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <26252c1699103f7efe51b224dd61bdb74e31f255.1403626729.git.vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: akpm@linux-foundation.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Jun 24, 2014 at 08:33:05PM +0400, Vladimir Davydov wrote:
> It's not used anywhere today, so let's remove it.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
