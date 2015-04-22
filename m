Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 580B36B0032
	for <linux-mm@kvack.org>; Wed, 22 Apr 2015 17:02:59 -0400 (EDT)
Received: by pacyx8 with SMTP id yx8so283164628pac.1
        for <linux-mm@kvack.org>; Wed, 22 Apr 2015 14:02:59 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id pr7si9347968pdb.236.2015.04.22.14.02.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Apr 2015 14:02:58 -0700 (PDT)
Date: Wed, 22 Apr 2015 14:02:57 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm/slab_common: Support the slub_debug boot option
 on specific object size
Message-Id: <20150422140257.eace5d4b83ae443099e6cf14@linux-foundation.org>
In-Reply-To: <20150422140039.19812721dff3fec674dc5134@linux-foundation.org>
References: <1429691618-13884-1-git-send-email-gavin.guo@canonical.com>
	<20150422140039.19812721dff3fec674dc5134@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gavin Guo <gavin.guo@canonical.com>, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 22 Apr 2015 14:00:39 -0700 Andrew Morton <akpm@linux-foundation.org> wrote:

> slab_kmem_cache_release() still does kfree_const(s->name).  It will
> crash?

er, ignore this bit..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
