Message-ID: <48A9CA10.80500@linux-foundation.org>
Date: Mon, 18 Aug 2008 14:14:24 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: [BUG] __GFP_THISNODE is not always honored
References: <1218837685.12953.11.camel@localhost.localdomain> <20080818105918.GD32113@csn.ul.ie>
In-Reply-To: <20080818105918.GD32113@csn.ul.ie>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Adam Litke <agl@us.ibm.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, nacc <nacc@linux.vnet.ibm.com>, apw <apw@shadowen.org>, agl <agl@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

> That's bad in itself and has wider reaching consequences than hugetlb
> getting its counters wrong. I believe SLUB depends on __GFP_THISNODE
> being obeyed for example. Can you boot the machine in question with
> mminit_loglevel=4 and loglevel=8 set on the command line and send me the
> dmesg please? It should output the zonelists and I might be able to
> figure out what's going wrong. Thanks

Its SLAB depends on it and will corrupt data if the wrong node is returned.
SLAB has BUG_ONs that should trigger if anything like that occurs.


> This will mask the bug for hugetlb but I wonder if this should be a
> VM_BUG_ON(page_to_nid(page) != nid) ?

Right.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
