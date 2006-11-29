Date: Tue, 28 Nov 2006 19:06:03 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Slab: Remove kmem_cache_t
Message-Id: <20061128190603.bcaac2e6.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0611281847030.12440@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0611281847030.12440@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 28 Nov 2006 18:49:23 -0800 (PST)
Christoph Lameter <clameter@sgi.com> wrote:

> This patch replaces all uses of kmem_cache_t with struct kmem_cache.
> 
> The patch was generated using the following script:
> 
> #!/bin/sh
> 
> #
> # Replace one string by another in all the kernel sources.
> #
> 
> set -e
> 
> for file in `find * -name "*.c" -o -name "*.h"|xargs grep -l $1`; do
> 	quilt add $file
> 	sed -e "1,\$s/$1/$2/g" $file >/tmp/$$
> 	mv /tmp/$$ $file
> 	quilt refresh
> done
> 
> 
> The script was run like this
> 
> 	sh replace kmem_cache_t "struct kmem_cache"

Fair enough.  Most of it applied.  Some didn't.  I'll sort it out.

> and then include/linux/slab.h was edited to remove the definition of
> kmem_cache_t.

But it's too early for this.

Happily, marking the typedef itself __deprecated appears to dtrt, so I dtt.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
