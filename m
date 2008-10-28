Date: Tue, 28 Oct 2008 20:07:20 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH 1/4][mmotm]  cgroup: make cgroup config as submenu
Message-Id: <20081028200720.1aa890fb.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20081028191008.d610de18.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081028190911.6857b0a6.kamezawa.hiroyu@jp.fujitsu.com>
	<20081028191008.d610de18.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "menage@google.com" <menage@google.com>, "xemul@openvz.org" <xemul@openvz.org>
List-ID: <linux-mm.kvack.org>

On Tue, 28 Oct 2008 19:10:08 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> Making CGROUP related configs to be sub-menu.
> 
> This patch will making CGROUP related configs to be sub-menu and
> making 1st level configs of "General Setup" shorter.
> 
>  including following additional changes 
>   - add help comment about CGROUPS and GROUP_SCHED.
>   - moved MM_OWNER config to the bottom.
>     (for good indent in menuconfig)
> 
> Changelog: v1->v2
>  - applied comments and fixed text.
>  - added precise "See Documentation..."
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
	Reviewed-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

> 
>  init/Kconfig |  123 ++++++++++++++++++++++++++++++++---------------------------
>  1 file changed, 67 insertions(+), 56 deletions(-)
> 
> Index: mmotm-2.6.28rc2+/init/Kconfig
> ===================================================================
> --- mmotm-2.6.28rc2+.orig/init/Kconfig
> +++ mmotm-2.6.28rc2+/init/Kconfig
> @@ -271,59 +271,6 @@ config LOG_BUF_SHIFT
>  		     13 =>  8 KB
>  		     12 =>  4 KB
>  
> -config CGROUPS
> -	bool "Control Group support"
> -	help
> -	  This option will let you use process cgroup subsystems
> -	  such as Cpusets
> -
> -	  Say N if unsure.
> -
> -config CGROUP_DEBUG
> -	bool "Example debug cgroup subsystem"
> -	depends on CGROUPS
> -	default n
> -	help
> -	  This option enables a simple cgroup subsystem that
> -	  exports useful debugging information about the cgroups
> -	  framework
> -
> -	  Say N if unsure
> -
> -config CGROUP_NS
> -        bool "Namespace cgroup subsystem"
> -        depends on CGROUPS
> -        help
> -          Provides a simple namespace cgroup subsystem to
> -          provide hierarchical naming of sets of namespaces,
> -          for instance virtual servers and checkpoint/restart
> -          jobs.
> -
> -config CGROUP_FREEZER
> -        bool "control group freezer subsystem"
> -        depends on CGROUPS
> -        help
> -          Provides a way to freeze and unfreeze all tasks in a
> -	  cgroup.
> -
> -config CGROUP_DEVICE
> -	bool "Device controller for cgroups"
> -	depends on CGROUPS && EXPERIMENTAL
> -	help
> -	  Provides a cgroup implementing whitelists for devices which
> -	  a process in the cgroup can mknod or open.
> -
> -config CPUSETS
> -	bool "Cpuset support"
> -	depends on SMP && CGROUPS
> -	help
> -	  This option will let you create and manage CPUSETs which
> -	  allow dynamically partitioning a system into sets of CPUs and
> -	  Memory Nodes and assigning tasks to run only within those sets.
> -	  This is primarily useful on large SMP or NUMA systems.
> -
> -	  Say N if unsure.
> -
>  #
>  # Architectures with an unreliable sched_clock() should select this:
>  #
> @@ -337,6 +284,8 @@ config GROUP_SCHED
>  	help
>  	  This feature lets CPU scheduler recognize task groups and control CPU
>  	  bandwidth allocation to such task groups.
> +	  In order to create a group from arbitrary set of processes, use
> +	  CONFIG_CGROUPS. (See Control Group support.)
>  
>  config FAIR_GROUP_SCHED
>  	bool "Group scheduling for SCHED_OTHER"
> @@ -379,6 +328,66 @@ config CGROUP_SCHED
>  
>  endchoice
>  
> +menu "Control Group support"
> +config CGROUPS
> +	bool "Control Group support"
> +	help
> +	  This option add support for grouping sets of processes together, for
> +	  use with process control subsystems such as Cpusets, CFS, memory
> +	  controls or device isolation.
> +	  See
> +		- Documentation/cpusets.txt	(Cpusets)
> +		- Documentation/scheduler/sched-design-CFS.txt	(CFS)
> +		- Documentation/cgroups/ (features for grouping, isolation)
> +		- Documentation/controllers/ (features for resource control)
> +
> +	  Say N if unsure.
> +
> +config CGROUP_DEBUG
> +	bool "Example debug cgroup subsystem"
> +	depends on CGROUPS
> +	default n
> +	help
> +	  This option enables a simple cgroup subsystem that
> +	  exports useful debugging information about the cgroups
> +	  framework
> +
> +	  Say N if unsure
> +
> +config CGROUP_NS
> +        bool "Namespace cgroup subsystem"
> +        depends on CGROUPS
> +        help
> +          Provides a simple namespace cgroup subsystem to
> +          provide hierarchical naming of sets of namespaces,
> +          for instance virtual servers and checkpoint/restart
> +          jobs.
> +
> +config CGROUP_FREEZER
> +        bool "control group freezer subsystem"
> +        depends on CGROUPS
> +        help
> +          Provides a way to freeze and unfreeze all tasks in a
> +	  cgroup.
> +
> +config CGROUP_DEVICE
> +	bool "Device controller for cgroups"
> +	depends on CGROUPS && EXPERIMENTAL
> +	help
> +	  Provides a cgroup implementing whitelists for devices which
> +	  a process in the cgroup can mknod or open.
> +
> +config CPUSETS
> +	bool "Cpuset support"
> +	depends on SMP && CGROUPS
> +	help
> +	  This option will let you create and manage CPUSETs which
> +	  allow dynamically partitioning a system into sets of CPUs and
> +	  Memory Nodes and assigning tasks to run only within those sets.
> +	  This is primarily useful on large SMP or NUMA systems.
> +
> +	  Say N if unsure.
> +
>  config CGROUP_CPUACCT
>  	bool "Simple CPU accounting cgroup subsystem"
>  	depends on CGROUPS
> @@ -393,9 +402,6 @@ config RESOURCE_COUNTERS
>            infrastructure that works with cgroups
>  	depends on CGROUPS
>  
> -config MM_OWNER
> -	bool
> -
>  config CGROUP_MEM_RES_CTLR
>  	bool "Memory Resource Controller for Control Groups"
>  	depends on CGROUPS && RESOURCE_COUNTERS
> @@ -419,6 +425,11 @@ config CGROUP_MEM_RES_CTLR
>  	  This config option also selects MM_OWNER config option, which
>  	  could in turn add some fork/exit overhead.
>  
> +config MM_OWNER
> +	bool
> +
> +endmenu
> +
>  config SYSFS_DEPRECATED
>  	bool
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
