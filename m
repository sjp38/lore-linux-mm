Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 0E4526B0038
	for <linux-mm@kvack.org>; Wed,  1 Apr 2015 11:17:25 -0400 (EDT)
Received: by pddn5 with SMTP id n5so58039448pdd.2
        for <linux-mm@kvack.org>; Wed, 01 Apr 2015 08:17:24 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id mc9si3316748pdb.203.2015.04.01.08.17.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Apr 2015 08:17:24 -0700 (PDT)
Date: Wed, 1 Apr 2015 18:17:17 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH] Documentation/memcg: update memcg/kmem status
Message-ID: <20150401151717.GE21839@esperanza>
References: <1427898636-4505-1-git-send-email-vdavydov@parallels.com>
 <20150401164431.1e88220a@lwn.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150401164431.1e88220a@lwn.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Apr 01, 2015 at 04:44:31PM +0200, Jonathan Corbet wrote:
> On Wed, 1 Apr 2015 17:30:36 +0300
> Vladimir Davydov <vdavydov@parallels.com> wrote:
> 
> > Memcg/kmem reclaim support has been finally merged. Reflect this in the
> > documentation.
> 
> So the text you've removed says not to select kmem support "unless for
> development purposes."  Do we now believe that this feature is ready for
> use in a production setting?  If the answer is "yes," I'd be happy to
> take this through the docs tree.

I added this warning because of the following issues, which made
memcg/kmem useless:

 - no reclaim support
 - lack of memcg slab caches auto destruction
 - several obvious races/bugs

They are all fixed now, so I think the answer is yes, it can be used in
production. There might be bugs that I am not aware of, of course, but
It must be safe to compile it in anyway, because memcg/kmem accounting
is disabled by default and must be enabled explicitly at runtime by
writing to cgroup/memory.kmem.limit_in_bytes.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
