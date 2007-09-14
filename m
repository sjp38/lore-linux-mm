Date: Fri, 14 Sep 2007 11:53:25 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 2/4] hugetlb: fix pool allocation with empty nodes
In-Reply-To: <20070906182430.GB7779@us.ibm.com>
Message-ID: <Pine.LNX.4.64.0709141152250.17038@schroedinger.engr.sgi.com>
References: <20070906182134.GA7779@us.ibm.com> <20070906182430.GB7779@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: anton@samba.org, wli@holomorphy.com, agl@us.ibm.com, lee.schermerhorn@hp.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 6 Sep 2007, Nishanth Aravamudan wrote:

>  	if (nid < 0)
> -		nid = first_node(node_online_map);
> +		nid = first_node(node_states[N_HIGH_MEMORY]);
>  	start_nid = nid;

Can huge pages live in high memory? Otherwise I think we could use
N_REGULAR_MEMORY here. There may be issues on 32 bit NUMA if we attempt to 
allocate memory from the highmem nodes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
