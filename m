Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 49FD76B0069
	for <linux-mm@kvack.org>; Tue, 27 Dec 2016 19:17:58 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 5so341571841pgj.6
        for <linux-mm@kvack.org>; Tue, 27 Dec 2016 16:17:58 -0800 (PST)
Received: from mail-pg0-x22e.google.com (mail-pg0-x22e.google.com. [2607:f8b0:400e:c05::22e])
        by mx.google.com with ESMTPS id p61si48047498plb.150.2016.12.27.16.17.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Dec 2016 16:17:57 -0800 (PST)
Received: by mail-pg0-x22e.google.com with SMTP id i5so84614882pgh.2
        for <linux-mm@kvack.org>; Tue, 27 Dec 2016 16:17:57 -0800 (PST)
Date: Tue, 27 Dec 2016 16:17:55 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2] slub: do not merge cache if slub_debug contains a
 never-merge flag
In-Reply-To: <20161226190855.GB2600@lp-laptop-d>
Message-ID: <alpine.DEB.2.10.1612271617450.57140@chino.kir.corp.google.com>
References: <20161222235959.GC6871@lp-laptop-d> <alpine.DEB.2.20.1612231228340.21172@east.gentwo.org> <20161223190023.GA9644@lp-laptop-d> <alpine.DEB.2.20.1612241708280.9536@east.gentwo.org> <20161226190855.GB2600@lp-laptop-d>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Grygorii Maistrenko <grygoriimkd@gmail.com>
Cc: Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>

On Mon, 26 Dec 2016, Grygorii Maistrenko wrote:

> In case CONFIG_SLUB_DEBUG_ON=n, find_mergeable() gets debug features
> from commandline but never checks if there are features from the
> SLAB_NEVER_MERGE set.
> As a result selected by slub_debug caches are always mergeable if they
> have been created without a custom constructor set or without one of the
> SLAB_* debug features on.
> 
> This moves the SLAB_NEVER_MERGE check below the flags update from
> commandline to make sure it won't merge the slab cache if one of the
> debug features is on.
> 
> Signed-off-by: Grygorii Maistrenko <grygoriimkd@gmail.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
