Date: Fri, 14 Sep 2007 11:51:37 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 1/4] hugetlb: search harder for memory in alloc_fresh_huge_page()
In-Reply-To: <20070906182134.GA7779@us.ibm.com>
Message-ID: <Pine.LNX.4.64.0709141149360.17038@schroedinger.engr.sgi.com>
References: <20070906182134.GA7779@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: wli@holomorphy.com, agl@us.ibm.com, lee.schermerhorn@hp.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 6 Sep 2007, Nishanth Aravamudan wrote:

> particular semantics for __GFP_THISNODE, which are newly enforced --
> that is, that the allocation won't go off-node -- still use
> page_to_nid() to guarantee we don't mess up the accounting.

Hmmm..... Suspicious?

> +static int alloc_fresh_huge_page(void)
> +{
> +	static int nid = -1;
> +	struct page *page;
> +	int start_nid;
> +	int next_nid;
> +	int ret = 0;
> +
> +	if (nid < 0)

nid was set to -1 so why the if statement?

> +		nid = first_node(node_online_map);
> +	start_nid = nid;

Replace the above with

start_nid = first_node(node_online_map)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
