Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id AED686B005D
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 12:06:46 -0400 (EDT)
Date: Thu, 2 Aug 2012 11:06:32 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC PATCH 16/23 V2] numa: add CONFIG_MOVABLE_NODE for
 movable-dedicated node
In-Reply-To: <1343875991-7533-17-git-send-email-laijs@cn.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1208021105540.23049@router.home>
References: <1343875991-7533-1-git-send-email-laijs@cn.fujitsu.com> <1343875991-7533-17-git-send-email-laijs@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lai Jiangshan <laijs@cn.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Paul Menage <paul@paulmenage.org>, Rob Landley <rob@landley.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Jarkko Sakkinen <jarkko.sakkinen@intel.com>, Matt Fleming <matt.fleming@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Yinghai Lu <yinghai@kernel.org>, David Rientjes <rientjes@google.com>, Bjorn Helgaas <bhelgaas@google.com>, Wanlong Gao <gaowanlong@cn.fujitsu.com>, Petr Holasek <pholasek@redhat.com>, Djalal Harouni <tixxdz@opendz.org>, Jiri Kosina <jkosina@suse.cz>, Laura Vasilescu <laura@rosedu.org>, WANG Cong <xiyou.wangcong@gmail.com>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Sam Ravnborg <sam@ravnborg.org>, Paul Gortmaker <paul.gortmaker@windriver.com>, Rusty Russell <rusty@rustcorp.com.au>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Jim Cromie <jim.cromie@gmail.com>, Pawel Moll <pawel.moll@arm.com>, Henrique de Moraes Holschuh <ibm-acpi@hmh.eng.br>, Oleg Nesterov <oleg@redhat.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Michal Nazarewicz <mina86@mina86.com>, Mel Gorman <mgorman@suse.de>, Hillf Danton <dhillf@gmail.com>, Gavin Shan <shangw@linux.vnet.ibm.com>, Wen Congyang <wency@cn.fujitsu.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Wang Sheng-Hui <shhuiw@gmail.com>, Minchan Kim <minchan@kernel.org>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, containers@lists.linux-foundation.org

On Thu, 2 Aug 2012, Lai Jiangshan wrote:

> +++ b/include/linux/nodemask.h
> @@ -380,7 +380,11 @@ enum node_states {
>  #else
>  	N_HIGH_MEMORY = N_NORMAL_MEMORY,
>  #endif
> +#ifdef CONFIG_MOVABLE_NODE
> +	N_MEMORY,		/* The node has memory(regular, high, movable) */

I like these comments. Could you add some to each of the different node
states and defined their purpose?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
