Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id D3E906B0044
	for <linux-mm@kvack.org>; Sat,  4 Aug 2012 09:56:00 -0400 (EDT)
Received: by vbkv13 with SMTP id v13so1848524vbk.14
        for <linux-mm@kvack.org>; Sat, 04 Aug 2012 06:55:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1343875991-7533-13-git-send-email-laijs@cn.fujitsu.com>
References: <1343875991-7533-1-git-send-email-laijs@cn.fujitsu.com>
	<1343875991-7533-13-git-send-email-laijs@cn.fujitsu.com>
Date: Sat, 4 Aug 2012 21:55:59 +0800
Message-ID: <CAJd=RBAbzxoH4eH=A3PhQuDO2W7hEkN=FeShQ3KnMh5sg7Wu6w@mail.gmail.com>
Subject: Re: [RFC PATCH 12/23 V2] vmscan: use N_MEMORY instead N_HIGH_MEMORY
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lai Jiangshan <laijs@cn.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Paul Menage <paul@paulmenage.org>, Rob Landley <rob@landley.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Jarkko Sakkinen <jarkko.sakkinen@intel.com>, Matt Fleming <matt.fleming@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Yinghai Lu <yinghai@kernel.org>, David Rientjes <rientjes@google.com>, Bjorn Helgaas <bhelgaas@google.com>, Wanlong Gao <gaowanlong@cn.fujitsu.com>, Petr Holasek <pholasek@redhat.com>, Djalal Harouni <tixxdz@opendz.org>, Jiri Kosina <jkosina@suse.cz>, Laura Vasilescu <laura@rosedu.org>, WANG Cong <xiyou.wangcong@gmail.com>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Sam Ravnborg <sam@ravnborg.org>, Paul Gortmaker <paul.gortmaker@windriver.com>, Rusty Russell <rusty@rustcorp.com.au>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Jim Cromie <jim.cromie@gmail.com>, Pawel Moll <pawel.moll@arm.com>, Henrique de Moraes Holschuh <ibm-acpi@hmh.eng.br>, Oleg Nesterov <oleg@redhat.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Michal Nazarewicz <mina86@mina86.com>, Mel Gorman <mgorman@suse.de>, Gavin Shan <shangw@linux.vnet.ibm.com>, Wen Congyang <wency@cn.fujitsu.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Wang Sheng-Hui <shhuiw@gmail.com>, Minchan Kim <minchan@kernel.org>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, containers@lists.linux-foundation.org

On Thu, Aug 2, 2012 at 10:53 AM, Lai Jiangshan <laijs@cn.fujitsu.com> wrote:
> N_HIGH_MEMORY stands for the nodes that has normal or high memory.
> N_MEMORY stands for the nodes that has any memory.
>
> The code here need to handle with the nodes which have memory, we should
> use N_MEMORY instead.
>
> Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
> ---

Acked-by: Hillf Danton <dhillf@gmail.com>

>  mm/vmscan.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 66e4310..1888026 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2921,7 +2921,7 @@ static int __devinit cpu_callback(struct notifier_block *nfb,
>         int nid;
>
>         if (action == CPU_ONLINE || action == CPU_ONLINE_FROZEN) {
> -               for_each_node_state(nid, N_HIGH_MEMORY) {
> +               for_each_node_state(nid, N_MEMORY) {
>                         pg_data_t *pgdat = NODE_DATA(nid);
>                         const struct cpumask *mask;
>
> @@ -2976,7 +2976,7 @@ static int __init kswapd_init(void)
>         int nid;
>
>         swap_setup();
> -       for_each_node_state(nid, N_HIGH_MEMORY)
> +       for_each_node_state(nid, N_MEMORY)
>                 kswapd_run(nid);
>         hotcpu_notifier(cpu_callback, 0);
>         return 0;
> --
> 1.7.1
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
