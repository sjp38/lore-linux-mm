Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f177.google.com (mail-ob0-f177.google.com [209.85.214.177])
	by kanga.kvack.org (Postfix) with ESMTP id 8FC796B0038
	for <linux-mm@kvack.org>; Sat,  4 Apr 2015 09:29:42 -0400 (EDT)
Received: by obvd1 with SMTP id d1so201162353obv.0
        for <linux-mm@kvack.org>; Sat, 04 Apr 2015 06:29:42 -0700 (PDT)
Received: from vena.lwn.net (tex.lwn.net. [70.33.254.29])
        by mx.google.com with ESMTPS id dw5si10513984oeb.87.2015.04.04.06.29.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 04 Apr 2015 06:29:41 -0700 (PDT)
Date: Sat, 4 Apr 2015 15:29:34 +0200
From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH] Documentation/memcg: update memcg/kmem status
Message-ID: <20150404152934.2db95051@lwn.net>
In-Reply-To: <20150401151717.GE21839@esperanza>
References: <1427898636-4505-1-git-send-email-vdavydov@parallels.com>
	<20150401164431.1e88220a@lwn.net>
	<20150401151717.GE21839@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, 1 Apr 2015 18:17:17 +0300
Vladimir Davydov <vdavydov@parallels.com> wrote:

> > So the text you've removed says not to select kmem support "unless for
> > development purposes."  Do we now believe that this feature is ready for
> > use in a production setting?  If the answer is "yes," I'd be happy to
> > take this through the docs tree.  
> 
> I added this warning because of the following issues, which made
> memcg/kmem useless:
> 
>  - no reclaim support
>  - lack of memcg slab caches auto destruction
>  - several obvious races/bugs
> 
> They are all fixed now, so I think the answer is yes, it can be used in
> production. There might be bugs that I am not aware of, of course, but
> It must be safe to compile it in anyway, because memcg/kmem accounting
> is disabled by default and must be enabled explicitly at runtime by
> writing to cgroup/memory.kmem.limit_in_bytes.

So I believe you, but I'm still a bit nervous about taking this one
because I can't really judge whether we should be advising people to turn
on this feature at this point or not.  A well-placed ack or two would
help there; otherwise, Andrew, if you think it makes sense, you can just
grab it :)

Thanks,

jon

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
