Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 5446F82F64
	for <linux-mm@kvack.org>; Tue, 22 Dec 2015 13:15:40 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id q3so99994246pav.3
        for <linux-mm@kvack.org>; Tue, 22 Dec 2015 10:15:40 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id gl10si5503320pac.164.2015.12.22.10.15.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Dec 2015 10:15:39 -0800 (PST)
Subject: Re: linux-next: Tree for Dec 22 (mm/memcontrol)
References: <20151222162955.3f366781@canb.auug.org.au>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <56799349.9090300@infradead.org>
Date: Tue, 22 Dec 2015 10:15:37 -0800
MIME-Version: 1.0
In-Reply-To: <20151222162955.3f366781@canb.auug.org.au>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>, linux-next@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

On 12/21/15 21:29, Stephen Rothwell wrote:
> Hi all,
> 
> Changes since 20151221:
> 

on i386 or x86_64:

when CONFIG_SLOB=y:

../mm/memcontrol.c: In function 'memcg_update_kmem_limit':
../mm/memcontrol.c:2974:3: error: implicit declaration of function 'memcg_online_kmem' [-Werror=implicit-function-declaration]
   ret = memcg_online_kmem(memcg);
   ^
../mm/memcontrol.c: In function 'mem_cgroup_css_alloc':
../mm/memcontrol.c:4229:2: error: too many arguments to function 'memcg_propagate_kmem'
  error = memcg_propagate_kmem(parent, memcg);
  ^
../mm/memcontrol.c:2949:12: note: declared here
 static int memcg_propagate_kmem(struct mem_cgroup *memcg)
            ^



-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
