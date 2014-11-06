Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id D6DD16B0095
	for <linux-mm@kvack.org>; Thu,  6 Nov 2014 06:00:12 -0500 (EST)
Received: by mail-pd0-f169.google.com with SMTP id y10so938840pdj.28
        for <linux-mm@kvack.org>; Thu, 06 Nov 2014 03:00:12 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id j4si5492917pdp.184.2014.11.06.03.00.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Nov 2014 03:00:11 -0800 (PST)
Date: Thu, 6 Nov 2014 13:59:59 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -mm 7/8] slab: introduce slab_free helper
Message-ID: <20141106105959.GD4839@esperanza>
References: <cover.1415046910.git.vdavydov@parallels.com>
 <439ae0a228e18af4ba909dce471a7e3d21005ef6.1415046910.git.vdavydov@parallels.com>
 <alpine.DEB.2.11.1411051241330.28485@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1411051241330.28485@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Nov 05, 2014 at 12:42:05PM -0600, Christoph Lameter wrote:
> Some comments would be good for the commit.

If it isn't too late, here it goes:

We have code duplication in kmem_cache_free/kfree. Let's move it to a
separate function.

> 
> Acked-by: Christoph Lameter <cl@linux.com>

Thank you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
