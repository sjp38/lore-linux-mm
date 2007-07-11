Date: Wed, 11 Jul 2007 16:48:11 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 10/12] Memoryless nodes: Update memory policy and page
 migration
Message-Id: <20070711164811.e94df898.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070710215456.394842768@sgi.com>
References: <20070710215339.110895755@sgi.com>
	<20070710215456.394842768@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, kxr@sgi.com, Nishanth Aravamudan <nacc@us.ibm.com>, linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Tue, 10 Jul 2007 14:52:15 -0700
Christoph Lameter <clameter@sgi.com> wrote:

> +			*nodes = node_memory_map;
>  		else
node_states[N_MEMORY]  ?


>  		check_pgd_range(vma, vma->vm_start, vma->vm_end,
> -				&node_online_map, MPOL_MF_STATS, md);
> +				&node_memory_map, MPOL_MF_STATS, md);
>  	}

Again here.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
