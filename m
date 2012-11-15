Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id D24A56B0062
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 20:29:35 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id xa7so850180pbc.14
        for <linux-mm@kvack.org>; Wed, 14 Nov 2012 17:29:35 -0800 (PST)
Date: Wed, 14 Nov 2012 17:29:33 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/2] mm: balloon_compaction.c needs asm-generic/bug.h
In-Reply-To: <50A43E64.3040709@infradead.org>
Message-ID: <alpine.DEB.2.00.1211141729050.4749@chino.kir.corp.google.com>
References: <20121114163042.64f0c0495663331b9c2d60d6@canb.auug.org.au> <50A43E64.3040709@infradead.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: Rafael Aquini <aquini@redhat.com>, Stephen Rothwell <sfr@canb.auug.org.au>, linux-mm@kvack.org, linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

On Wed, 14 Nov 2012, Randy Dunlap wrote:

> From: Randy Dunlap <rdunlap@infradead.org>
> 
> Fix build when CONFIG_BUG is not enabled by adding header file
> <asm-generic/bug.h>:
> 
> mm/balloon_compaction.c: In function 'balloon_page_putback':
> mm/balloon_compaction.c:243:3: error: implicit declaration of function '__WARN'
> 

This is fixed by 
mm-introduce-a-common-interface-for-balloon-pages-mobility-fix-fix-fix.patch 
in -mm which converts it to WARN_ON(1) which is the generic way to trigger 
a warning.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
