Date: Thu, 10 Apr 2003 09:59:30 -0400
From: Benjamin LaHaise <bcrl@redhat.com>
Subject: Re: [PATCH] bootmem speedup from the IA64 tree
Message-ID: <20030410095930.D9136@redhat.com>
References: <20030410122421.A17889@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030410122421.A17889@lst.de>; from hch@lst.de on Thu, Apr 10, 2003 at 12:24:21PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: akpm@zip.com.au, davidm@napali.hpl.hp.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 10, 2003 at 12:24:21PM +0200, Christoph Hellwig wrote:
>  	if (goal && (goal >= bdata->node_boot_start) && 
> -			((goal >> PAGE_SHIFT) < bdata->node_low_pfn)) {
> +	    ((goal >> PAGE_SHIFT) < bdata->node_low_pfn)) {
>  		preferred = goal - bdata->node_boot_start;
> +
> +		if (last_success >= preferred)
> +			preferred = last_success;

I suspect you need a range check on last_success here for machines which have 
multiple nodes of memory, or else store it in bdata.

		-ben
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
