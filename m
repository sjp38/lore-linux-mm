Date: Mon, 3 Dec 2007 09:24:18 -0500
From: Rik van Riel <riel@redhat.com>
Subject: Re: [RFC][for -mm] memory controller enhancements for reclaiming
 take2 [5/8] throttling simultaneous callers of try_to_free_mem_cgroup_pages
Message-ID: <20071203092418.58631593@bree.surriel.com>
In-Reply-To: <20071203183921.72005b21.kamezawa.hiroyu@jp.fujitsu.com>
References: <20071203183355.0061ddeb.kamezawa.hiroyu@jp.fujitsu.com>
	<20071203183921.72005b21.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>, Andrew Morton <akpm@linux-foundation.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

On Mon, 3 Dec 2007 18:39:21 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> Add throttling direct reclaim.
> 
> Trying heavy workload under memory controller, you'll see too much
> iowait and system seems heavy. (This is not good.... memory controller
> is usually used for isolating system workload)
> And too much memory are reclaimed.
> 
> This patch adds throttling function for direct reclaim.
> Currently, num_online_cpus/(4) + 1 threads can do direct memory reclaim
> under memory controller.

The same problems are true of global reclaim.

Now that we're discussing this RFC anyway, I wonder if we
should think about moving this restriction to the global
reclaim level...

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
