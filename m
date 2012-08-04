Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 5CE4B6B0044
	for <linux-mm@kvack.org>; Sat,  4 Aug 2012 09:51:22 -0400 (EDT)
Received: by vcbfl10 with SMTP id fl10so1843045vcb.14
        for <linux-mm@kvack.org>; Sat, 04 Aug 2012 06:51:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1343875991-7533-3-git-send-email-laijs@cn.fujitsu.com>
References: <1343875991-7533-1-git-send-email-laijs@cn.fujitsu.com>
	<1343875991-7533-3-git-send-email-laijs@cn.fujitsu.com>
Date: Sat, 4 Aug 2012 21:51:21 +0800
Message-ID: <CAJd=RBDuGh26YxLGA2AdM4eu7-ZZAO8jjrJm4ZPjc62f3XZj5w@mail.gmail.com>
Subject: Re: [RFC PATCH 02/23 V2] cpuset: use N_MEMORY instead N_HIGH_MEMORY
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lai Jiangshan <laijs@cn.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Paul Menage <paul@paulmenage.org>, Rob Landley <rob@landley.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Jarkko Sakkinen <jarkko.sakkinen@intel.com>, Matt Fleming <matt.fleming@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Yinghai Lu <yinghai@kernel.org>, David Rientjes <rientjes@google.com>, Bjorn Helgaas <bhelgaas@google.com>, Wanlong Gao <gaowanlong@cn.fujitsu.com>, Petr Holasek <pholasek@redhat.com>, Djalal Harouni <tixxdz@opendz.org>, Jiri Kosina <jkosina@suse.cz>, Laura Vasilescu <laura@rosedu.org>, WANG Cong <xiyou.wangcong@gmail.com>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Sam Ravnborg <sam@ravnborg.org>, Paul Gortmaker <paul.gortmaker@windriver.com>, Rusty Russell <rusty@rustcorp.com.au>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Jim Cromie <jim.cromie@gmail.com>, Pawel Moll <pawel.moll@arm.com>, Henrique de Moraes Holschuh <ibm-acpi@hmh.eng.br>, Oleg Nesterov <oleg@redhat.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Michal Nazarewicz <mina86@mina86.com>, Mel Gorman <mgorman@suse.de>, Gavin Shan <shangw@linux.vnet.ibm.com>, Wen Congyang <wency@cn.fujitsu.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Wang Sheng-Hui <shhuiw@gmail.com>, Minchan Kim <minchan@kernel.org>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, containers@lists.linux-foundation.org

On Thu, Aug 2, 2012 at 10:52 AM, Lai Jiangshan <laijs@cn.fujitsu.com> wrote:
> N_HIGH_MEMORY stands for the nodes that has normal or high memory.
> N_MEMORY stands for the nodes that has any memory.
>
> The code here need to handle with the nodes which have memory, we should
> use N_MEMORY instead.
>

As described in the change log of 01/23, N_MEMORY is introduced to be
alias of N_HIGH_MEMORY, but the above sounds like you are correcting
the usage of N_HIGH_MEMORY.

> Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
> ---

Other than that,

Acked-by: Hillf Danton <dhillf@gmail.com>


>  Documentation/cgroups/cpusets.txt |    2 +-
>  include/linux/cpuset.h            |    2 +-
>  kernel/cpuset.c                   |   32 ++++++++++++++++----------------
>  3 files changed, 18 insertions(+), 18 deletions(-)
>
> diff --git a/Documentation/cgroups/cpusets.txt b/Documentation/cgroups/cpusets.txt
> index cefd3d8..12e01d4 100644
> --- a/Documentation/cgroups/cpusets.txt
> +++ b/Documentation/cgroups/cpusets.txt
> @@ -218,7 +218,7 @@ and name space for cpusets, with a minimum of additional kernel code.
>  The cpus and mems files in the root (top_cpuset) cpuset are
>  read-only.  The cpus file automatically tracks the value of
>  cpu_online_mask using a CPU hotplug notifier, and the mems file
> -automatically tracks the value of node_states[N_HIGH_MEMORY]--i.e.,
> +automatically tracks the value of node_states[N_MEMORY]--i.e.,
>  nodes with memory--using the cpuset_track_online_nodes() hook.
>
>
> diff --git a/include/linux/cpuset.h b/include/linux/cpuset.h
> index 838320f..8c8a60d 100644
> --- a/include/linux/cpuset.h
> +++ b/include/linux/cpuset.h
> @@ -144,7 +144,7 @@ static inline nodemask_t cpuset_mems_allowed(struct task_struct *p)
>         return node_possible_map;
>  }
>
> -#define cpuset_current_mems_allowed (node_states[N_HIGH_MEMORY])
> +#define cpuset_current_mems_allowed (node_states[N_MEMORY])
>  static inline void cpuset_init_current_mems_allowed(void) {}
>
>  static inline int cpuset_nodemask_valid_mems_allowed(nodemask_t *nodemask)
> diff --git a/kernel/cpuset.c b/kernel/cpuset.c
> index f33c715..2b133db 100644
> --- a/kernel/cpuset.c
> +++ b/kernel/cpuset.c
> @@ -302,10 +302,10 @@ static void guarantee_online_cpus(const struct cpuset *cs,
>   * are online, with memory.  If none are online with memory, walk
>   * up the cpuset hierarchy until we find one that does have some
>   * online mems.  If we get all the way to the top and still haven't
> - * found any online mems, return node_states[N_HIGH_MEMORY].
> + * found any online mems, return node_states[N_MEMORY].
>   *
>   * One way or another, we guarantee to return some non-empty subset
> - * of node_states[N_HIGH_MEMORY].
> + * of node_states[N_MEMORY].
>   *
>   * Call with callback_mutex held.
>   */
> @@ -313,14 +313,14 @@ static void guarantee_online_cpus(const struct cpuset *cs,
>  static void guarantee_online_mems(const struct cpuset *cs, nodemask_t *pmask)
>  {
>         while (cs && !nodes_intersects(cs->mems_allowed,
> -                                       node_states[N_HIGH_MEMORY]))
> +                                       node_states[N_MEMORY]))
>                 cs = cs->parent;
>         if (cs)
>                 nodes_and(*pmask, cs->mems_allowed,
> -                                       node_states[N_HIGH_MEMORY]);
> +                                       node_states[N_MEMORY]);
>         else
> -               *pmask = node_states[N_HIGH_MEMORY];
> -       BUG_ON(!nodes_intersects(*pmask, node_states[N_HIGH_MEMORY]));
> +               *pmask = node_states[N_MEMORY];
> +       BUG_ON(!nodes_intersects(*pmask, node_states[N_MEMORY]));
>  }
>
>  /*
> @@ -1100,7 +1100,7 @@ static int update_nodemask(struct cpuset *cs, struct cpuset *trialcs,
>                 return -ENOMEM;
>
>         /*
> -        * top_cpuset.mems_allowed tracks node_stats[N_HIGH_MEMORY];
> +        * top_cpuset.mems_allowed tracks node_stats[N_MEMORY];
>          * it's read-only
>          */
>         if (cs == &top_cpuset) {
> @@ -1122,7 +1122,7 @@ static int update_nodemask(struct cpuset *cs, struct cpuset *trialcs,
>                         goto done;
>
>                 if (!nodes_subset(trialcs->mems_allowed,
> -                               node_states[N_HIGH_MEMORY])) {
> +                               node_states[N_MEMORY])) {
>                         retval =  -EINVAL;
>                         goto done;
>                 }
> @@ -2034,7 +2034,7 @@ static struct cpuset *cpuset_next(struct list_head *queue)
>   * before dropping down to the next.  It always processes a node before
>   * any of its children.
>   *
> - * In the case of memory hot-unplug, it will remove nodes from N_HIGH_MEMORY
> + * In the case of memory hot-unplug, it will remove nodes from N_MEMORY
>   * if all present pages from a node are offlined.
>   */
>  static void
> @@ -2073,7 +2073,7 @@ scan_cpusets_upon_hotplug(struct cpuset *root, enum hotplug_event event)
>
>                         /* Continue past cpusets with all mems online */
>                         if (nodes_subset(cp->mems_allowed,
> -                                       node_states[N_HIGH_MEMORY]))
> +                                       node_states[N_MEMORY]))
>                                 continue;
>
>                         oldmems = cp->mems_allowed;
> @@ -2081,7 +2081,7 @@ scan_cpusets_upon_hotplug(struct cpuset *root, enum hotplug_event event)
>                         /* Remove offline mems from this cpuset. */
>                         mutex_lock(&callback_mutex);
>                         nodes_and(cp->mems_allowed, cp->mems_allowed,
> -                                               node_states[N_HIGH_MEMORY]);
> +                                               node_states[N_MEMORY]);
>                         mutex_unlock(&callback_mutex);
>
>                         /* Move tasks from the empty cpuset to a parent */
> @@ -2134,8 +2134,8 @@ void cpuset_update_active_cpus(bool cpu_online)
>
>  #ifdef CONFIG_MEMORY_HOTPLUG
>  /*
> - * Keep top_cpuset.mems_allowed tracking node_states[N_HIGH_MEMORY].
> - * Call this routine anytime after node_states[N_HIGH_MEMORY] changes.
> + * Keep top_cpuset.mems_allowed tracking node_states[N_MEMORY].
> + * Call this routine anytime after node_states[N_MEMORY] changes.
>   * See cpuset_update_active_cpus() for CPU hotplug handling.
>   */
>  static int cpuset_track_online_nodes(struct notifier_block *self,
> @@ -2148,7 +2148,7 @@ static int cpuset_track_online_nodes(struct notifier_block *self,
>         case MEM_ONLINE:
>                 oldmems = top_cpuset.mems_allowed;
>                 mutex_lock(&callback_mutex);
> -               top_cpuset.mems_allowed = node_states[N_HIGH_MEMORY];
> +               top_cpuset.mems_allowed = node_states[N_MEMORY];
>                 mutex_unlock(&callback_mutex);
>                 update_tasks_nodemask(&top_cpuset, &oldmems, NULL);
>                 break;
> @@ -2177,7 +2177,7 @@ static int cpuset_track_online_nodes(struct notifier_block *self,
>  void __init cpuset_init_smp(void)
>  {
>         cpumask_copy(top_cpuset.cpus_allowed, cpu_active_mask);
> -       top_cpuset.mems_allowed = node_states[N_HIGH_MEMORY];
> +       top_cpuset.mems_allowed = node_states[N_MEMORY];
>
>         hotplug_memory_notifier(cpuset_track_online_nodes, 10);
>
> @@ -2245,7 +2245,7 @@ void cpuset_init_current_mems_allowed(void)
>   *
>   * Description: Returns the nodemask_t mems_allowed of the cpuset
>   * attached to the specified @tsk.  Guaranteed to return some non-empty
> - * subset of node_states[N_HIGH_MEMORY], even if this means going outside the
> + * subset of node_states[N_MEMORY], even if this means going outside the
>   * tasks cpuset.
>   **/
>
> --
> 1.7.1
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
