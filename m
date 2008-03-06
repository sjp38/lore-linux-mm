From: kamezawa.hiroyu@jp.fujitsu.com
Message-ID: <6197904.1204808216900.kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 6 Mar 2008 21:56:56 +0900 (JST)
Subject: Re: Re: [RFC/PATCH] cgroup swap subsystem
In-Reply-To: <47CFD957.3060402@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
References: <47CFD957.3060402@mxp.nes.nec.co.jp>
 <47CE36A9.3060204@mxp.nes.nec.co.jp> <20080305155329.60e02f48.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, containers@lists.osdl.org, linux-mm@kvack.org, balbir@linux.vnet.ibm.com, xemul@openvz.org, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

>> At first look, remembering mm struct is not very good.
>> Remembering swap controller itself is better.
>
>The swap_cgroup when the page(and page_cgroup) is allocated and
>the swap_cgroup when the page is going to be swapped out may be
>different by swap_cgroup_move_task(), so I think swap_cgroup
>to be charged should be determined at the point of swapout.
>
Accounting swap against an entity which allocs anon memory is
not strange. Problem here is move_task itself.
Now, charges against anon is not moved when a task which uses it
is moved. please fix this behavior first if you think this is
problematic.

But, finally, a daemon driven by process event connector
determines the group before process starts using anon. It's
doubtful that it's worth to add complicated/costly ones.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
