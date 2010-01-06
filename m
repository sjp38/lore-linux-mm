Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3D8E56B003D
	for <linux-mm@kvack.org>; Wed,  6 Jan 2010 12:29:56 -0500 (EST)
Date: Wed, 6 Jan 2010 17:29:45 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/7] Export unusable free space index via
	/proc/pagetypeinfo
Message-ID: <20100106172945.GA5426@csn.ul.ie>
References: <1262795169-9095-1-git-send-email-mel@csn.ul.ie> <1262795169-9095-3-git-send-email-mel@csn.ul.ie> <1262797848.3579.8.camel@aglitke>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1262797848.3579.8.camel@aglitke>
Sender: owner-linux-mm@kvack.org
To: Adam Litke <agl@us.ibm.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Avi Kivity <avi@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 06, 2010 at 11:10:48AM -0600, Adam Litke wrote:
> On Wed, 2010-01-06 at 16:26 +0000, Mel Gorman wrote:
> > +/*
> > + * Return an index indicating how much of the available free memory is
> > + * unusable for an allocation of the requested size.
> > + */
> > +int unusable_free_index(struct zone *zone,
> > +				unsigned int order,
> > +				struct config_page_info *info)
> > +{
> > +	/* No free memory is interpreted as all free memory is unusable */
> > +	if (info->free_pages == 0)
> > +		return 100;
> 
> Should the above be 1000?
> 

Yes. Fortunately, the value is not actually used by any of the code.
It's for consumption by people or tools.

Thanks

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
