Date: Thu, 3 Jul 2008 12:06:43 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][-mm] [0/7] misc memcg patch set
Message-Id: <20080703120643.e74552d9.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080702210322.518f6c43.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080702210322.518f6c43.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "hugh@veritas.com" <hugh@veritas.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2 Jul 2008 21:03:22 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> Hi, it seems vmm-related bugs in -mm is reduced to some safe level.
> I restarted my patches for memcg.
> 
> This mail is just for dumping patches on my stack.
> (I'll resend one by one later.)
> 
> based on 2.6.26-rc5-mm3
> + kosaki's fixes + cgroup write_string set + Hugh Dickins's fixes for shmem
> (All patches are in -mm queue.)
> 
> Any comments are welcome (but 7/7 patch is not so neat...)
> 
> [1/7] swapcache handle fix for shmem.
> [2/7] adjust to split-lru: remove PAGE_CGROUP_FLAG_CACHE flag. 
> [3/7] adjust to split-lru: push shmem's page to active list
>       (Imported from Hugh Dickins's work.)
> [4/7] reduce usage at change limit. res_counter part.
> [5/7] reduce usage at change limit. memcg part.
> [6/7] memcg-background-job.           res_coutner part
> [7/7] memcg-background-job            memcg part.

I decied to rewrite 7/7, totally. 
And add more sophisticated memcg-threadpool. (like pdflush)
So, please ignore 7/7.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
