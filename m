Date: Thu, 7 Jun 2007 15:05:56 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH v2] gfp.h: GFP_THISNODE can go to other nodes if some
 are unpopulated
In-Reply-To: <20070607220149.GC15776@us.ibm.com>
Message-ID: <Pine.LNX.4.64.0706071505330.28899@schroedinger.engr.sgi.com>
References: <20070607150425.GA15776@us.ibm.com>
 <Pine.LNX.4.64.0706071103240.24988@schroedinger.engr.sgi.com>
 <20070607220149.GC15776@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Lee.Schermerhorn@hp.com, anton@samba.org, apw@shadowen.org, mel@csn.ul.ie, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 7 Jun 2007, Nishanth Aravamudan wrote:

>  /*
> - * NOTE: if the requested node is unpopulated (no memory), a THISNODE
> - * request can go to other nodes due to the fallback list
> + * NOTE: GFP_THISNODE allocates from the first available pgdat (== node
> + * structure) from the zonelist of the requested node. The first pgdat
> + * may be the pgdat of another node if the requested node has no memory
> + * on its own.
>   */
>  #define GFP_THISNODE	(__GFP_THISNODE | __GFP_NOWARN | __GFP_NORETRY)
>  #else

Acked-by: Christoph Lameter <clameter@sgi.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
