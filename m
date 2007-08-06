Date: Mon, 6 Aug 2007 10:59:20 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC][PATCH 2/5] hugetlb: numafy several functions
In-Reply-To: <20070806163841.GL15714@us.ibm.com>
Message-ID: <Pine.LNX.4.64.0708061058380.24256@schroedinger.engr.sgi.com>
References: <20070806163254.GJ15714@us.ibm.com> <20070806163726.GK15714@us.ibm.com>
 <20070806163841.GL15714@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: lee.schermerhorn@hp.com, wli@holomorphy.com, melgor@ie.ibm.com, akpm@linux-foundation.org, linux-mm@kvack.org, agl@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Mon, 6 Aug 2007, Nishanth Aravamudan wrote:

> +	page = alloc_pages_node(nid,
> +			GFP_HIGHUSER|__GFP_COMP|GFP_THISNODE,
> +			HUGETLB_PAGE_ORDER);

GFP_THISNODE disables reclaim. With Mel Gorman's ZONE_MOVABLE you may want 
to enable reclaim here. Use __GFP_THISNODE?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
