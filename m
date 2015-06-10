Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vn0-f49.google.com (mail-vn0-f49.google.com [209.85.216.49])
	by kanga.kvack.org (Postfix) with ESMTP id 13D986B0032
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 21:11:39 -0400 (EDT)
Received: by vnbg190 with SMTP id g190so5565225vnb.6
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 18:11:38 -0700 (PDT)
Received: from resqmta-ch2-10v.sys.comcast.net (resqmta-ch2-10v.sys.comcast.net. [2001:558:fe21:29:69:252:207:42])
        by mx.google.com with ESMTPS id ey7si13186854vdb.99.2015.06.09.18.11.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 09 Jun 2015 18:11:27 -0700 (PDT)
Date: Tue, 9 Jun 2015 20:11:25 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC][PATCH 0/5] do not dereference NULL pools in pools' destroy()
 functions
In-Reply-To: <20150609142523.b717dba6033ee08de997c8be@linux-foundation.org>
Message-ID: <alpine.DEB.2.11.1506092008220.3300@east.gentwo.org>
References: <1433851493-23685-1-git-send-email-sergey.senozhatsky@gmail.com> <20150609142523.b717dba6033ee08de997c8be@linux-foundation.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Minchan Kim <minchan@kernel.org>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, sergey.senozhatsky.work@gmail.com, Joe Perches <joe@perches.com>

On Tue, 9 Jun 2015, Andrew Morton wrote:

> Well I like it, even though it's going to cause a zillion little cleanup
> patches.
>
> checkpatch already has a "kfree(NULL) is safe and this check is
> probably not required" test so I guess Joe will need to get busy ;)
>
> I'll park these patches until after 4.1 is released - it's getting to
> that time...

Why do this at all? I understand that kfree/kmem_cache_free can take a
null pointer but this is the destruction of a cache and it usually
requires multiple actions to clean things up and these actions have to be
properly sequenced. All other processors have to stop referencing this
cache before it can be destroyed. I think failing if someone does
something strange like doing cache destruction with a NULL pointer is
valuable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
