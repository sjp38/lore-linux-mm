Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f177.google.com (mail-lb0-f177.google.com [209.85.217.177])
	by kanga.kvack.org (Postfix) with ESMTP id E72A46B00CF
	for <linux-mm@kvack.org>; Thu,  8 May 2014 02:40:56 -0400 (EDT)
Received: by mail-lb0-f177.google.com with SMTP id s7so2788531lbd.8
        for <linux-mm@kvack.org>; Wed, 07 May 2014 23:40:56 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id og9si23667lbb.171.2014.05.07.23.40.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 May 2014 23:40:54 -0700 (PDT)
Date: Thu, 8 May 2014 10:40:37 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -mm v2 0/6] memcg/kmem: cleanup naming and callflows
Message-ID: <20140508064035.GF4757@esperanza>
References: <cover.1398587474.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <cover.1398587474.git.vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.cz, hannes@cmpxchg.org, glommer@gmail.com, cl@linux-foundation.org, penberg@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org

Seems this set looks too big for anybody to spend time reviewing it, so
I'm going to split and resend it (actually already started) to ease
review. Please, ignore this one and sorry for the noise.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
