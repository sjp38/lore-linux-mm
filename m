Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id AFE796B0005
	for <linux-mm@kvack.org>; Thu, 22 Feb 2018 22:19:58 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id g5so1145418itf.1
        for <linux-mm@kvack.org>; Thu, 22 Feb 2018 19:19:58 -0800 (PST)
Received: from resqmta-ch2-11v.sys.comcast.net (resqmta-ch2-11v.sys.comcast.net. [2001:558:fe21:29:69:252:207:43])
        by mx.google.com with ESMTPS id t42si1037975ioi.99.2018.02.22.19.19.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Feb 2018 19:19:57 -0800 (PST)
Date: Thu, 22 Feb 2018 21:19:55 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH v2 0/3] Directed kmem charging
In-Reply-To: <20180221125426.464f894d29a0b6e525b2e3be@linux-foundation.org>
Message-ID: <alpine.DEB.2.20.1802222117140.6687@nuc-kabylake>
References: <20180221030101.221206-1-shakeelb@google.com> <alpine.DEB.2.20.1802211002200.12567@nuc-kabylake> <CALvZod68LD-wnbm2+MQks=bd_D2zY64uScUBp28hyug_vaGyDA@mail.gmail.com> <20180221125426.464f894d29a0b6e525b2e3be@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Shakeel Butt <shakeelb@google.com>, Jan Kara <jack@suse.cz>, Amir Goldstein <amir73il@gmail.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Cgroups <cgroups@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, 21 Feb 2018, Andrew Morton wrote:

> What do others think?

I think the changes to the hotpaths of the slab allocators increasing
register pressure in some of the hotttest paths of the kernel are
problematic.

Its better to do the allocation properly in the task context to which it
is finally charged. There may be other restrictions that emerge from other
fields in the task_struct that also may influence allocation and reclaim
behavior. It is cleanest to do this in the proper task context instead of
taking a piece (like the cgroup) out of context.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
