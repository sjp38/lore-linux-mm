Message-ID: <4836563B.4060603@anu.edu.au>
Date: Fri, 23 May 2008 15:29:31 +1000
From: David Singleton <David.Singleton@anu.edu.au>
Reply-To: David.Singleton@anu.edu.au
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] swapcgroup(v2)
References: <20080523121027.b0eecfa0.kamezawa.hiroyu@jp.fujitsu.com> <4836411B.2030601@linux.vnet.ibm.com> <20080523131812.84F1.KOSAKI.MOTOHIRO@jp.fujitsu.com> <48364D38.7000304@linux.vnet.ibm.com>
In-Reply-To: <48364D38.7000304@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Linux Containers <containers@lists.osdl.org>, Linux MM <linux-mm@kvack.org>, Pavel Emelyanov <xemul@openvz.org>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Hugh Dickins <hugh@veritas.com>, "IKEDA, Munehiro" <m-ikeda@ds.jp.nec.com>
List-ID: <linux-mm.kvack.org>

Balbir Singh wrote:
> KOSAKI Motohiro wrote:
>>> One option is to limit the virtual address space usage of the cgroup to ensure
>>> that swap usage of a cgroup will *not* exceed the specified limit. Along with a
>>> good swap controller, it should provide good control over the cgroup's memory usage.
>> unfortunately, it doesn't works in real world.
>> IMHO you said as old good age.
>>
>> because, Some JavaVM consume crazy large virtual address space.
>> it often consume >10x than phycal memory consumption.
>>
> 
> Have you seen any real world example of this? 

At the unsophisticated end, there are lots of (Fortran) HPC applications
with very large static array declarations but only "use" a small fraction
of that.  Those users know they only need a small fraction and are happy
to volunteer small physical memory limits that we (admins/queuing
systems) can apply.

At the sophisticated end, the use of numerous large memory maps in
parallel HPC applications to gain visibility into other processes is
growing.  We have processes with VSZ > 400GB just because they have
4GB maps into 127 other processes.  Their physical page use is of
the order 2GB.

Imposing virtual address space limits on these applications is
meaningless.


The overcommit feature of Linux.
> We usually by default limit the overcommit to 1.5 times total memory (IIRC).
> Yes, one can override that value, you get the same flexibility with the virtual
> address space controller.
> 
> I thought java was particular about it with it's heap management options and policy.
> 
>> yes, that behaviour is crazy. but it is used widely.
>> thus, We shouldn't assume virtual address space limitation.
> 
> It's useful in many cases to limit the virtual address space - to allow
> applications to deal with memory failure, rather than
> 
> 1. OOM the application later
> 2. Allow uncontrolled swapping (swap controller would help here)
> 

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
