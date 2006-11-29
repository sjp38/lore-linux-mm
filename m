Subject: Re: Slab: Remove kmem_cache_t
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <Pine.LNX.4.64.0611281847030.12440@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0611281847030.12440@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Wed, 29 Nov 2006 09:50:07 +0100
Message-Id: <1164790207.32474.24.camel@taijtu>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2006-11-28 at 18:49 -0800, Christoph Lameter wrote:
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


find . -name .pc -prune -o -name \*.[ch] | xargs grep -l $1 | 
while read file; do
  quilt add $file
  sed -ie "1,\$s/$1/$2/g" $file
  quilt refresh --strip-trailing-whitespace
done


- this will skip the .pc directory where quilt resides, so you could do
multiple iterations of this script.

- does in-place replacement with sed

- doesn't do the find in back-ticks which can cause it to run out of env
space.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
