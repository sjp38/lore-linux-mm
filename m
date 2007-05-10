Date: Thu, 10 May 2007 11:09:29 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC] memory hotremove patch take 2 [05/10] (make basic remove
 code)
In-Reply-To: <20070509120512.B910.Y-GOTO@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0705101108251.10002@schroedinger.engr.sgi.com>
References: <20070509115506.B904.Y-GOTO@jp.fujitsu.com>
 <20070509120512.B910.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Wed, 9 May 2007, Yasunori Goto wrote:

> +/*
> + * Just an easy implementation.
> + */
> +static struct page *
> +hotremove_migrate_alloc(struct page *page,
> +			unsigned long private,
> +			int **x)
> +{
> +	return alloc_page(GFP_HIGH_MOVABLE);
> +}

This would need to reflect the zone in which you are performing hot 
remove. Or is hot remove only possible in the higest zone?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
