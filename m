Date: Thu, 27 Mar 2008 18:14:04 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][1/3] Add user interface for virtual address space control
 (v2)
Message-Id: <20080327181404.1e95a725.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080326185006.9465.4720.sendpatchset@localhost.localdomain>
References: <20080326184954.9465.19379.sendpatchset@localhost.localdomain>
	<20080326185006.9465.4720.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Thu, 27 Mar 2008 00:20:06 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> 
> 
> Add as_usage_in_bytes and as_limit_in_bytes interfaces. These provide
> control over the total address space that the processes combined together
> in the cgroup can grow upto. This functionality is analogous to
> the RLIMIT_AS function of the getrlimit(2) and setrlimit(2) calls.
> A as_res resource counter is added to the mem_cgroup structure. The
> as_res counter handles all the accounting associated with the virtual
> address space accounting and control of cgroups.
> 
> Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>

I wonder that it's better to create "rlimit cgroup" rather than enhancing
memory controller. (But I have no strong opinion.)
How do you think ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
