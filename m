Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f42.google.com (mail-qa0-f42.google.com [209.85.216.42])
	by kanga.kvack.org (Postfix) with ESMTP id DECEA6B006C
	for <linux-mm@kvack.org>; Wed,  5 Nov 2014 13:42:09 -0500 (EST)
Received: by mail-qa0-f42.google.com with SMTP id k15so946483qaq.15
        for <linux-mm@kvack.org>; Wed, 05 Nov 2014 10:42:09 -0800 (PST)
Received: from resqmta-ch2-08v.sys.comcast.net (resqmta-ch2-08v.sys.comcast.net. [2001:558:fe21:29:69:252:207:40])
        by mx.google.com with ESMTPS id m10si7626078qct.27.2014.11.05.10.42.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 05 Nov 2014 10:42:08 -0800 (PST)
Date: Wed, 5 Nov 2014 12:42:05 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH -mm 7/8] slab: introduce slab_free helper
In-Reply-To: <439ae0a228e18af4ba909dce471a7e3d21005ef6.1415046910.git.vdavydov@parallels.com>
Message-ID: <alpine.DEB.2.11.1411051241330.28485@gentwo.org>
References: <cover.1415046910.git.vdavydov@parallels.com> <439ae0a228e18af4ba909dce471a7e3d21005ef6.1415046910.git.vdavydov@parallels.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Some comments would be good for the commit.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
