Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id E5F656B0005
	for <linux-mm@kvack.org>; Wed,  3 Aug 2016 10:14:53 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id p129so126296145wmp.3
        for <linux-mm@kvack.org>; Wed, 03 Aug 2016 07:14:53 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id gs9si8198473wjc.36.2016.08.03.07.14.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Aug 2016 07:14:52 -0700 (PDT)
Date: Wed, 3 Aug 2016 10:14:46 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v3 3/3] mm: memcontrol: add sanity checks for
 memcg->id.ref on get/put
Message-ID: <20160803141446.GB12838@cmpxchg.org>
References: <5336daa5c9a32e776067773d9da655d2dc126491.1470219853.git.vdavydov@virtuozzo.com>
 <1c5ddb1c171dbdfc3262252769d6138a29b35b70.1470219853.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1c5ddb1c171dbdfc3262252769d6138a29b35b70.1470219853.git.vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Aug 03, 2016 at 01:35:08PM +0300, Vladimir Davydov wrote:
> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
> Acked-by: Michal Hocko <mhocko@suse.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
