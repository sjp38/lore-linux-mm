Date: Fri, 14 Sep 2007 11:54:58 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 3/4] hugetlb: interleave dequeueing of huge pages
In-Reply-To: <20070906182704.GC7779@us.ibm.com>
Message-ID: <Pine.LNX.4.64.0709141153360.17038@schroedinger.engr.sgi.com>
References: <20070906182134.GA7779@us.ibm.com> <20070906182430.GB7779@us.ibm.com>
 <20070906182704.GC7779@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: wli@holomorphy.com, agl@us.ibm.com, lee.schermerhorn@hp.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 6 Sep 2007, Nishanth Aravamudan wrote:

> +static struct page *dequeue_huge_page(void)
> +{
> +	static int nid = -1;
> +	struct page *page = NULL;
> +	int start_nid;
> +	int next_nid;
> +
> +	if (nid < 0)
> +		nid = first_node(node_states[N_HIGH_MEMORY]);
> +	start_nid = nid;

nid is -1 so the tests are useless.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
