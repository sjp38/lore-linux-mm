Message-ID: <482B8FE4.4020301@cn.fujitsu.com>
Date: Thu, 15 May 2008 09:20:36 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [-mm][PATCH 1/4] Add memrlimit controller documentation (v4)
References: <20080514130904.24440.23486.sendpatchset@localhost.localdomain> <20080514130915.24440.56106.sendpatchset@localhost.localdomain>
In-Reply-To: <20080514130915.24440.56106.sendpatchset@localhost.localdomain>
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, linux-kernel@vger.kernel.org, Pavel Emelianov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Balbir Singh wrote:
> Documentation patch - describes the goals and usage of the memrlimit
> controller.
> 
> 
> Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> ---
> 
>  Documentation/controllers/memrlimit.txt |   29 +++++++++++++++++++++++++++++
>  1 file changed, 29 insertions(+)
> 
> diff -puN /dev/null Documentation/controllers/memrlimit.txt
> --- /dev/null	2008-05-14 04:27:30.032276540 +0530
> +++ linux-2.6.26-rc2-balbir/Documentation/controllers/memrlimit.txt	2008-05-14 18:35:55.000000000 +0530
> @@ -0,0 +1,29 @@
> +This controller is enabled by the CONFIG_CGROUP_MEMRLIMIT_CTLR option. Prior
> +to reading this documentation please read Documentation/cgroups.txt and
> +Documentation/controllers/memory.txt. Several of the principles of this
> +controller are similar to the memory resource controller.
> +
> +This controller framework is designed to be extensible to control any
> +memory resource limit with little effort.
> +
> +This new controller, controls the address space expansion of the tasks
> +belonging to a cgroup. Address space control is provided along the same lines as
> +RLIMIT_AS control, which is available via getrlimit(2)/setrlimit(2).
> +The interface for controlling address space is provided through
> +"rlimit.limit_in_bytes". The file is similar to "limit_in_bytes" w.r.t. the user

    memrlimit.limit_in_bytes

> +interface. Please see section 3 of the memory resource controller documentation
> +for more details on how to use the user interface to get and set values.
> +
> +The "memrlimit.usage_in_bytes" file provides information about the total address
> +space usage of the tasks in the cgroup, in bytes.
> +
> +Advantages of providing this feature
> +
> +1. Control over virtual address space allows for a cgroup to fail gracefully
> +   i.e., via a malloc or mmap failure as compared to OOM kill when no
> +   pages can be reclaimed.
> +2. It provides better control over how many pages can be swapped out when
> +   the cgroup goes over its limit. A badly setup cgroup can cause excessive
> +   swapping. Providing control over the address space allocations ensures
> +   that the system administrator has control over the total swapping that
> +   can take place.
> _
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
