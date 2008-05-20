Message-ID: <48329421.8080904@openvz.org>
Date: Tue, 20 May 2008 13:04:33 +0400
From: Pavel Emelyanov <xemul@openvz.org>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 1/3] memcg: documentation for controll file
References: <20080520180552.601da567.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080520180552.601da567.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "menage@google.com" <menage@google.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> Add a documentation for memory resource controller's files.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

I have described some files, that should be created by a control group,
which uses a res_counter in Documentation/controllers/resource_counter.txt
section 4.

Maybe it's worth adding a reference to this file, or even rework this
text? How do you think?

> Index: mm-2.6.26-rc2-mm1/Documentation/controllers/memory_files.txt
> ===================================================================
> --- /dev/null
> +++ mm-2.6.26-rc2-mm1/Documentation/controllers/memory_files.txt
> @@ -0,0 +1,76 @@
> +Files under memory resource controller and its resource counter.
> +(See controllers/memory.txt about memory resource controller)
> +
> +* memory.usage_in_bytes
> +  (read)
> +  Currently accounted memory usage under memory controller in bytes.
> +  multiple of PAGE_SIZE.
> +
> +  Even if there is no tasks under controller, some page caches and
> +  swap caches are still accounted. (See memory.force_empty below.)
> +
> +  (write)
> +  no write operation
> +
> +* memory.limit_in_bytes
> +  (read)
> +  Current limit of usage to this memory resource controller in bytes.
> +  (write)
> +  Set limit to this memory resource controller.
> +  A user can use "K', 'M', 'G' to specify the limit.
> +
> +  (Example) You can set limit of 400M by following.
> +  % echo 400M > /path to cgroup/memory.limit_in_bytes
> +
> +* memory.max_usage_in_bytes
> +  (read)
> +  Recorded maximum memory usage under this memory controller.
> +
> +  (write)
> +  Reset the record to 0.
> +
> +  (example usage)
> +  1. create a cgroup
> +  % mkdir /path_to_cgroup/my_cgroup.
> +
> +  2. enter the cgroup
> +  % echo $$ > /path_to_cgroup/my_cgroup/tasks.
> +
> +  3. Run your program
> +  % Run......
> +
> +  4. See how much you used.
> +  % cat /path_to_cgroup/my_cgroup/memory.max_usage_in_bytes.
> +
> +  Now you know how much your application will use. Maybe this
> +  can be a good to set  limits_in_bytes to some proper value.
> +
> +* memory.force_empty
> +  (read)
> +  not allowed.
> +  (write)
> +  Drop all charges under cgroup. This can be called only when
> +  there is no task under this cgroup. This is here for debug purpose.
> +
> +* memory.stat
> +  (read)
> +  show 6 values. (will change in future)
> +  cache          .... usage accounted as File-Cache.
> +  anon/swapcache .... usage accounted as anonymous memory or swapcache.
> +  pgpgin         .... # of page-in under this cgroup.
> +  pgpgout        .... # of page-out under this cgroup
> +  active         .... amounts of memory which is treated as 'active' 
> +  inactive       .... amounts of memory which is treated as 'inactive'
> +  (write)
> +  not allowed 
> +
> +* memory.failcnt
> +  (read)
> +  The number of blocked memory allocation.
> +  Until the usage reaches the limit, memory allocation is not blocked.
> +  When it reaches, memory allocation is blocked and try to reclaim memory
> +  from LRU.
> +
> +  (write)
> +  Reset to 0.
> +
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
