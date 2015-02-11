Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f182.google.com (mail-qc0-f182.google.com [209.85.216.182])
	by kanga.kvack.org (Postfix) with ESMTP id CB09D6B0032
	for <linux-mm@kvack.org>; Wed, 11 Feb 2015 10:44:36 -0500 (EST)
Received: by mail-qc0-f182.google.com with SMTP id x3so3450504qcv.13
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 07:44:36 -0800 (PST)
Received: from resqmta-ch2-03v.sys.comcast.net (resqmta-ch2-03v.sys.comcast.net. [2001:558:fe21:29:69:252:207:35])
        by mx.google.com with ESMTPS id r4si1183313qah.77.2015.02.11.07.44.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 11 Feb 2015 07:44:36 -0800 (PST)
Date: Wed, 11 Feb 2015 09:44:34 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH -mm] slub: kmem_cache_shrink: init discard list after
 freeing slabs
In-Reply-To: <20150211154128.GA26049@esperanza>
Message-ID: <alpine.DEB.2.11.1502110944180.3120@gentwo.org>
References: <1423627463.5968.99.camel@intel.com> <1423642582-23553-1-git-send-email-vdavydov@parallels.com> <alpine.DEB.2.11.1502110851180.32065@gentwo.org> <alpine.DEB.2.11.1502110857410.948@gentwo.org> <20150211154128.GA26049@esperanza>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Wed, 11 Feb 2015, Vladimir Davydov wrote:

> > Also the promote array should also be initialized in the loop right?
>
> I do initialize promote lists in the loop using list_splice_init, but
> yeah, initializing them in the beginning of the loop would look more
> readable indeed. The updated patch is below. Thanks!

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
