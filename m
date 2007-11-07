Date: Wed, 7 Nov 2007 19:54:53 +0100
From: =?utf-8?B?SsO2cm4=?= Engel <joern@logfs.org>
Subject: Re: [patch 04/23] dentries: Extract common code to remove dentry from lru
Message-ID: <20071107185452.GD8918@lazybastard.org>
References: <20071107011130.382244340@sgi.com> <20071107011227.298491275@sgi.com> <20071107085027.GA6243@cataract> <20071107094348.GB7374@lazybastard.org> <Pine.LNX.4.64.0711071054240.11906@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <Pine.LNX.4.64.0711071054240.11906@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: =?utf-8?B?SsO2cm4=?= Engel <joern@logfs.org>, Johannes Weiner <hannes-kernel@saeurebad.de>, akpm@linux-foundatin.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>
List-ID: <linux-mm.kvack.org>

On Wed, 7 November 2007 10:55:09 -0800, Christoph Lameter wrote:
> 
> From: Christoph Lameter <clameter@sgi.com>
> Subject: dcache: use the correct variable.
> 
> We need to use "loop" instead of "dentry"
> 
> Acked-by: Joern Engel <joern@logfs.org>
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> 
> Index: linux-2.6/fs/dcache.c
> ===================================================================
> --- linux-2.6.orig/fs/dcache.c	2007-11-07 10:26:20.000000000 -0800
> +++ linux-2.6/fs/dcache.c	2007-11-07 10:26:27.000000000 -0800
> @@ -610,7 +610,7 @@ static void shrink_dcache_for_umount_sub
>  			spin_lock(&dcache_lock);
>  			list_for_each_entry(loop, &dentry->d_subdirs,
>  					    d_u.d_child) {
> -				dentry_lru_remove(dentry);
> +				dentry_lru_remove(loop);
>  				__d_drop(loop);
>  				cond_resched_lock(&dcache_lock);
>  			}

Erm - wouldn't this break git-bisect?

JA?rn

-- 
Joern's library part 5:
http://www.faqs.org/faqs/compression-faq/part2/section-9.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
