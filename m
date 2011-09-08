Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 959D16B019E
	for <linux-mm@kvack.org>; Thu,  8 Sep 2011 13:46:28 -0400 (EDT)
Message-ID: <4E68FF70.1010709@xenotime.net>
Date: Thu, 08 Sep 2011 10:46:24 -0700
From: Randy Dunlap <rdunlap@xenotime.net>
MIME-Version: 1.0
Subject: Re: [PATCH v2 9/9] Add documentation about kmem_cgroup
References: <1315369399-3073-1-git-send-email-glommer@parallels.com> <1315369399-3073-10-git-send-email-glommer@parallels.com>
In-Reply-To: <1315369399-3073-10-git-send-email-glommer@parallels.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, netdev@vger.kernel.org, xemul@parallels.com, "David S. Miller" <davem@davemloft.net>, Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>, "Eric W. Biederman" <ebiederm@xmission.com>

On 09/06/11 21:23, Glauber Costa wrote:
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> CC: David S. Miller <davem@davemloft.net>
> CC: Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>
> CC: Eric W. Biederman <ebiederm@xmission.com>
> CC: Randy Dunlap <rdunlap@xenotime.net>
> ---
>  Documentation/cgroups/kmem_cgroups.txt |   27 +++++++++++++++++++++++++++
>  1 files changed, 27 insertions(+), 0 deletions(-)
>  create mode 100644 Documentation/cgroups/kmem_cgroups.txt
> 
> diff --git a/Documentation/cgroups/kmem_cgroups.txt b/Documentation/cgroups/kmem_cgroups.txt
> new file mode 100644
> index 0000000..930e069
> --- /dev/null
> +++ b/Documentation/cgroups/kmem_cgroups.txt
> @@ -0,0 +1,27 @@
> +Kernel Memory Cgroup
> +====================
> +
> +This document briefly describes the kernel memory cgroup, or "kmem cgroup".
> +Unlike user memory, kernel memory cannot be swapped. This effectively means
> +that rogue processes can start operations that pin kernel objects permanently
> +into memory, exhausting resources of all other processes in the system.
> +
> +kmem_cgroup main goal is to control the amount of memory a group of processes

   kmem_cgroup's main goal

> +can pin at any given point in time. Other uses of this infrastructure are
> +expected to come up with time. Right now, the only resource effectively limited

                                                      resources

> +are tcp send and receive buffers.

or:
                                             the only resource effectively limited
  is TCP network buffers.

> +
> +TCP network buffers
> +===================
> +
> +TCP network buffers, both on the send and receive sides, can be controlled
> +by the kmem cgroup. Once a socket is created, it is attached to the cgroup of
> +the controller process, where it stays until the end of its lifetime.
> +
> +Files
> +=====
> +	kmem.tcp_maxmem: control the maximum amount in bytes that can be used by

	                 controls the maximum amount of memory in bytes ...


> +	tcp sockets inside the cgroup. 
> +
> +	kmem.tcp_current_memory: current amount in bytes used by all sockets in

	                         current amount of memory in bytes ...

> +	this cgroup


-- 
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
