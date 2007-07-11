Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l6BGuau3025321
	for <linux-mm@kvack.org>; Wed, 11 Jul 2007 12:56:36 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l6BGuCRE126542
	for <linux-mm@kvack.org>; Wed, 11 Jul 2007 10:56:35 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6BGb16k023708
	for <linux-mm@kvack.org>; Wed, 11 Jul 2007 10:37:01 -0600
Date: Wed, 11 Jul 2007 09:37:00 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [patch 10/12] Memoryless nodes: Update memory policy and page migration
Message-ID: <20070711163700.GP27655@us.ibm.com>
References: <20070710215339.110895755@sgi.com> <20070710215456.394842768@sgi.com> <20070711164811.e94df898.kamezawa.hiroyu@jp.fujitsu.com> <20070711161653.GN27655@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070711161653.GN27655@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Christoph Lameter <clameter@sgi.com>, akpm@linux-foundation.org, kxr@sgi.com, linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On 11.07.2007 [09:16:53 -0700], Nishanth Aravamudan wrote:
> On 11.07.2007 [16:48:11 +0900], KAMEZAWA Hiroyuki wrote:
> > On Tue, 10 Jul 2007 14:52:15 -0700
> > Christoph Lameter <clameter@sgi.com> wrote:
> > 
> > > +			*nodes = node_memory_map;
> > >  		else
> > node_states[N_MEMORY]  ?
> > 
> > 
> > >  		check_pgd_range(vma, vma->vm_start, vma->vm_end,
> > > -				&node_online_map, MPOL_MF_STATS, md);
> > > +				&node_memory_map, MPOL_MF_STATS, md);
> > >  	}
> > 
> > Again here.
> 
> I think Christoph missed a hunk in the node_memory_map patch, which
> would
> 
> #define node_memory_map node_stats[N_MEMORY]

Or maybe it's intentional -- and your changes are appropriate (and
in-line with the other changes Christoph's patches made).

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
