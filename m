Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f174.google.com (mail-yk0-f174.google.com [209.85.160.174])
	by kanga.kvack.org (Postfix) with ESMTP id 63F946B0038
	for <linux-mm@kvack.org>; Wed, 11 Feb 2015 10:00:41 -0500 (EST)
Received: by mail-yk0-f174.google.com with SMTP id 9so1626866ykp.5
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 07:00:41 -0800 (PST)
Received: from resqmta-ch2-02v.sys.comcast.net (resqmta-ch2-02v.sys.comcast.net. [2001:558:fe21:29:69:252:207:34])
        by mx.google.com with ESMTPS id e88si1148852qga.58.2015.02.11.07.00.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 11 Feb 2015 07:00:40 -0800 (PST)
Date: Wed, 11 Feb 2015 09:00:39 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH -mm] slub: kmem_cache_shrink: init discard list after
 freeing slabs
In-Reply-To: <alpine.DEB.2.11.1502110851180.32065@gentwo.org>
Message-ID: <alpine.DEB.2.11.1502110857410.948@gentwo.org>
References: <1423627463.5968.99.camel@intel.com> <1423642582-23553-1-git-send-email-vdavydov@parallels.com> <alpine.DEB.2.11.1502110851180.32065@gentwo.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Hmmmm... Thinking about this some more. It may be better to initialize the
list head at the beginning of the loop?

Also the promote array should also be initialized in the loop right?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
