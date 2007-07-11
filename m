Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l6BGGtD6028680
	for <linux-mm@kvack.org>; Wed, 11 Jul 2007 12:16:55 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l6BGGscJ551304
	for <linux-mm@kvack.org>; Wed, 11 Jul 2007 12:16:54 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6BGGsJk002099
	for <linux-mm@kvack.org>; Wed, 11 Jul 2007 12:16:54 -0400
Date: Wed, 11 Jul 2007 09:16:53 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [patch 10/12] Memoryless nodes: Update memory policy and page migration
Message-ID: <20070711161653.GN27655@us.ibm.com>
References: <20070710215339.110895755@sgi.com> <20070710215456.394842768@sgi.com> <20070711164811.e94df898.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070711164811.e94df898.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Christoph Lameter <clameter@sgi.com>, akpm@linux-foundation.org, kxr@sgi.com, linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On 11.07.2007 [16:48:11 +0900], KAMEZAWA Hiroyuki wrote:
> On Tue, 10 Jul 2007 14:52:15 -0700
> Christoph Lameter <clameter@sgi.com> wrote:
> 
> > +			*nodes = node_memory_map;
> >  		else
> node_states[N_MEMORY]  ?
> 
> 
> >  		check_pgd_range(vma, vma->vm_start, vma->vm_end,
> > -				&node_online_map, MPOL_MF_STATS, md);
> > +				&node_memory_map, MPOL_MF_STATS, md);
> >  	}
> 
> Again here.

I think Christoph missed a hunk in the node_memory_map patch, which
would

#define node_memory_map node_stats[N_MEMORY]

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
