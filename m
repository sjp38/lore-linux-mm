Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id A8DC56B0062
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 14:14:56 -0400 (EDT)
Date: Thu, 14 Jun 2012 13:14:53 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Common [19/20] Allocate kmem_cache structure in slab_common.c
In-Reply-To: <4FD9BE30.4000005@parallels.com>
Message-ID: <alpine.DEB.2.00.1206141312520.12773@router.home>
References: <20120613152451.465596612@linux.com> <20120613152525.596813300@linux.com> <CAOJsxLE-7XCzbAi-M=sBkPymAj25yNGvAs6ea-ZyaEbDJo3+cA@mail.gmail.com> <4FD9BE30.4000005@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII; FORMAT=flowed
Content-ID: <alpine.DEB.2.00.1206141312522.12773@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Joonsoo Kim <js1304@gmail.com>

Merge what you are comfortable with and I will have a look at the rest.
Just the initial cleanups for the allocators maybe?

I applied glommers' fix but my machine also will not boot with the whole
set.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
