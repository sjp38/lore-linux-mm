Date: Wed, 7 Nov 2007 09:50:27 +0100
From: Johannes Weiner <hannes-kernel@saeurebad.de>
Subject: Re: [patch 04/23] dentries: Extract common code to remove dentry from lru
Message-ID: <20071107085027.GA6243@cataract>
References: <20071107011130.382244340@sgi.com> <20071107011227.298491275@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20071107011227.298491275@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundatin.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>
List-ID: <linux-mm.kvack.org>

Hi Christoph,

On Tue, Nov 06, 2007 at 05:11:34PM -0800, Christoph Lameter wrote:
> @@ -613,11 +606,7 @@ static void shrink_dcache_for_umount_sub
>  			spin_lock(&dcache_lock);
>  			list_for_each_entry(loop, &dentry->d_subdirs,
>  					    d_u.d_child) {
> -				if (!list_empty(&loop->d_lru)) {
> -					dentry_stat.nr_unused--;
> -					list_del_init(&loop->d_lru);
> -				}
> -
> +				dentry_lru_remove(dentry);

Shouldn't this be dentry_lru_remove(loop)?

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
