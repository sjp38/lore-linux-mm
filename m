Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f48.google.com (mail-qa0-f48.google.com [209.85.216.48])
	by kanga.kvack.org (Postfix) with ESMTP id 9EA516B0032
	for <linux-mm@kvack.org>; Wed, 11 Feb 2015 09:51:35 -0500 (EST)
Received: by mail-qa0-f48.google.com with SMTP id v8so2881702qal.7
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 06:51:35 -0800 (PST)
Received: from resqmta-ch2-02v.sys.comcast.net (resqmta-ch2-02v.sys.comcast.net. [2001:558:fe21:29:69:252:207:34])
        by mx.google.com with ESMTPS id i5si1155671qcn.11.2015.02.11.06.51.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 11 Feb 2015 06:51:34 -0800 (PST)
Date: Wed, 11 Feb 2015 08:51:33 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH -mm] slub: kmem_cache_shrink: init discard list after
 freeing slabs
In-Reply-To: <1423642582-23553-1-git-send-email-vdavydov@parallels.com>
Message-ID: <alpine.DEB.2.11.1502110851180.32065@gentwo.org>
References: <1423627463.5968.99.camel@intel.com> <1423642582-23553-1-git-send-email-vdavydov@parallels.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Wed, 11 Feb 2015, Vladimir Davydov wrote:

> Otherwise, if there are > 1 nodes, we can get use-after-free while
> processing the second or higher node:

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
