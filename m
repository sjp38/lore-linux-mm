Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id E71486B003D
	for <linux-mm@kvack.org>; Wed,  6 Jan 2010 12:10:57 -0500 (EST)
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e3.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o06H191J016086
	for <linux-mm@kvack.org>; Wed, 6 Jan 2010 12:01:09 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o06HAqWx094446
	for <linux-mm@kvack.org>; Wed, 6 Jan 2010 12:10:52 -0500
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o06HAqH5022943
	for <linux-mm@kvack.org>; Wed, 6 Jan 2010 10:10:52 -0700
Subject: Re: [PATCH 2/7] Export unusable free space index via
 /proc/pagetypeinfo
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <1262795169-9095-3-git-send-email-mel@csn.ul.ie>
References: <1262795169-9095-1-git-send-email-mel@csn.ul.ie>
	 <1262795169-9095-3-git-send-email-mel@csn.ul.ie>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 06 Jan 2010 11:10:48 -0600
Message-ID: <1262797848.3579.8.camel@aglitke>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Avi Kivity <avi@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2010-01-06 at 16:26 +0000, Mel Gorman wrote:
> +/*
> + * Return an index indicating how much of the available free memory is
> + * unusable for an allocation of the requested size.
> + */
> +int unusable_free_index(struct zone *zone,
> +				unsigned int order,
> +				struct config_page_info *info)
> +{
> +	/* No free memory is interpreted as all free memory is unusable */
> +	if (info->free_pages == 0)
> +		return 100;

Should the above be 1000?


-- 
Thanks,
Adam

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
