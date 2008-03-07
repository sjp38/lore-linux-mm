Message-Id: <47D0FB45.1030209@mxp.nes.nec.co.jp>
Date: Fri, 07 Mar 2008 17:22:29 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Subject: Re: [RFC/PATCH] cgroup swap subsystem
References: <47CFD957.3060402@mxp.nes.nec.co.jp> <47CE36A9.3060204@mxp.nes.nec.co.jp> <20080305155329.60e02f48.kamezawa.hiroyu@jp.fujitsu.com> <6197904.1204808216900.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <6197904.1204808216900.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kamezawa.hiroyu@jp.fujitsu.com
Cc: containers@lists.osdl.org, linux-mm@kvack.org, balbir@linux.vnet.ibm.com, xemul@openvz.org, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

Hi.

kamezawa.hiroyu@jp.fujitsu.com wrote:
>>> At first look, remembering mm struct is not very good.
>>> Remembering swap controller itself is better.
>> The swap_cgroup when the page(and page_cgroup) is allocated and
>> the swap_cgroup when the page is going to be swapped out may be
>> different by swap_cgroup_move_task(), so I think swap_cgroup
>> to be charged should be determined at the point of swapout.
>>
> Accounting swap against an entity which allocs anon memory is
> not strange. Problem here is move_task itself.
> Now, charges against anon is not moved when a task which uses it
> is moved. please fix this behavior first if you think this is
> problematic.
> 
> But, finally, a daemon driven by process event connector
> determines the group before process starts using anon. It's
> doubtful that it's worth to add complicated/costly ones.
> 

I agree with you.

I think the current behavior of move_task is problematic,
and should fix it.
But fixing it would be difficult and add a costly process,
so I should consider more.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
