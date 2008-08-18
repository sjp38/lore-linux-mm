Message-ID: <48A9CBB3.6030700@linux-foundation.org>
Date: Mon, 18 Aug 2008 14:21:23 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: [BUG] __GFP_THISNODE is not always honored
References: <1218837685.12953.11.camel@localhost.localdomain>
In-Reply-To: <1218837685.12953.11.camel@localhost.localdomain>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, nacc <nacc@linux.vnet.ibm.com>, mel@csn.ul.ie, apw <apw@shadowen.org>, agl <agl@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Adam Litke wrote:
>
> So far my debugging has led me to get_page_from_freelist() inside the
> for_each_zone_zonelist() loop.  When buffered_rmqueue() returns a page I
> compare the value of page_to_nid(page), zone->node and the node that the
> hugetlb code requested with __GFP_THISNODE.  These all match -- except when the
> problem triggers.  In that case, zone->node matches the node we asked for but
> page_to_nid() does not.

Uhhh.. A page that was just taken off the freelist? So we may have freed or
coalesced a page to the wrong zone? Looks like there is something more
fundamental that broke here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
