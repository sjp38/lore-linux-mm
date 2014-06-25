Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id B325B6B0031
	for <linux-mm@kvack.org>; Wed, 25 Jun 2014 00:01:31 -0400 (EDT)
Received: by mail-wi0-f178.google.com with SMTP id n15so1699912wiw.5
        for <linux-mm@kvack.org>; Tue, 24 Jun 2014 21:01:31 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id e6si17815945wix.75.2014.06.24.21.01.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 24 Jun 2014 21:01:30 -0700 (PDT)
Date: Wed, 25 Jun 2014 00:01:18 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH -mm 1/3] page-cgroup: trivial cleanup
Message-ID: <20140625040118.GP7331@cmpxchg.org>
References: <9f5abf8dcb07fe5462f12f81867f199c22e883d3.1403626729.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9f5abf8dcb07fe5462f12f81867f199c22e883d3.1403626729.git.vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: akpm@linux-foundation.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Jun 24, 2014 at 08:33:04PM +0400, Vladimir Davydov wrote:
> Add forward declarations for struct pglist_data, mem_cgroup.
> 
> Remove __init, __meminit from function prototypes and inline functions.
> 
> Remove redundant inclusion of bit_spinlock.h.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
