Date: Sat, 1 Sep 2007 11:04:10 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC 14/26] SLUB: __GFP_MOVABLE and SLAB_TEMPORARY support
Message-Id: <20070901110410.acea7b2b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070901014222.536517408@sgi.com>
References: <20070901014107.719506437@sgi.com>
	<20070901014222.536517408@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: apw@shadowen.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, hch@lst.de, mel@skynet.ie, dgc@sgi.com
List-ID: <linux-mm.kvack.org>

On Fri, 31 Aug 2007 18:41:21 -0700
Christoph Lameter <clameter@sgi.com> wrote:

> +#ifndef CONFIG_HIGHMEM
> +	if (s->kick || s->flags & SLAB_TEMPORARY)
> +		flags |= __GFP_MOVABLE;
> +#endif
> +

Should I do this as

#if !defined(CONFIG_HIGHMEM) && !defined(CONFIG_MEMORY_HOTREMOVE)

?

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
