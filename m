Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 81D8982F64
	for <linux-mm@kvack.org>; Tue, 22 Dec 2015 14:19:35 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id cy9so39070776pac.0
        for <linux-mm@kvack.org>; Tue, 22 Dec 2015 11:19:35 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id sm5si4258852pab.0.2015.12.22.11.19.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Dec 2015 11:19:34 -0800 (PST)
Date: Tue, 22 Dec 2015 11:19:33 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: linux-next: Tree for Dec 22 (mm/memcontrol)
Message-Id: <20151222111933.088b73264cb997c8f96ca362@linux-foundation.org>
In-Reply-To: <56799349.9090300@infradead.org>
References: <20151222162955.3f366781@canb.auug.org.au>
	<56799349.9090300@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, Linux MM <linux-mm@kvack.org>

On Tue, 22 Dec 2015 10:15:37 -0800 Randy Dunlap <rdunlap@infradead.org> wrote:

> On 12/21/15 21:29, Stephen Rothwell wrote:
> > Hi all,
> > 
> > Changes since 20151221:
> > 
> 
> on i386 or x86_64:
> 
> when CONFIG_SLOB=y:
> 
> ../mm/memcontrol.c: In function 'memcg_update_kmem_limit':
> ../mm/memcontrol.c:2974:3: error: implicit declaration of function 'memcg_online_kmem' [-Werror=implicit-function-declaration]
>    ret = memcg_online_kmem(memcg);
>    ^
> ../mm/memcontrol.c: In function 'mem_cgroup_css_alloc':
> ../mm/memcontrol.c:4229:2: error: too many arguments to function 'memcg_propagate_kmem'
>   error = memcg_propagate_kmem(parent, memcg);
>   ^
> ../mm/memcontrol.c:2949:12: note: declared here
>  static int memcg_propagate_kmem(struct mem_cgroup *memcg)
>             ^

I can't reproduce this.  config, please?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
