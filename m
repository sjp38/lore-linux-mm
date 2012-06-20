Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 018A66B0062
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 03:08:00 -0400 (EDT)
Received: by ggm4 with SMTP id 4so6762882ggm.14
        for <linux-mm@kvack.org>; Wed, 20 Jun 2012 00:07:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1206141312520.12773@router.home>
References: <20120613152451.465596612@linux.com>
	<20120613152525.596813300@linux.com>
	<CAOJsxLE-7XCzbAi-M=sBkPymAj25yNGvAs6ea-ZyaEbDJo3+cA@mail.gmail.com>
	<4FD9BE30.4000005@parallels.com>
	<alpine.DEB.2.00.1206141312520.12773@router.home>
Date: Wed, 20 Jun 2012 10:07:59 +0300
Message-ID: <CAOJsxLF2Ku8FJ7Rs5D6-ZT_52aYsTn-eUZw_yaqetwJDQp9vBA@mail.gmail.com>
Subject: Re: Common [19/20] Allocate kmem_cache structure in slab_common.c
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Joonsoo Kim <js1304@gmail.com>

On Thu, Jun 14, 2012 at 9:14 PM, Christoph Lameter <cl@linux.com> wrote:
> Merge what you are comfortable with and I will have a look at the rest.
> Just the initial cleanups for the allocators maybe?

I merged patches up to "slab: Get rid of obj_size macro". If Glauber
already fixed any of the remaining patches, please just resend them.

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
