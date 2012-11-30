Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id EF16F6B00B3
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 10:08:13 -0500 (EST)
Subject: =?utf-8?q?Re=3A_=5BPATCH_for_3=2E2=2E34=5D_memcg=3A_do_not_trigger_OOM_from_add=5Fto=5Fpage=5Fcache=5Flocked?=
Date: Fri, 30 Nov 2012 16:08:11 +0100
From: "azurIt" <azurit@pobox.sk>
References: <20121123100438.GF24698@dhcp22.suse.cz>, <20121125011047.7477BB5E@pobox.sk>, <20121125120524.GB10623@dhcp22.suse.cz>, <20121125135542.GE10623@dhcp22.suse.cz>, <20121126013855.AF118F5E@pobox.sk>, <20121126131837.GC17860@dhcp22.suse.cz>, <20121126132149.GD17860@dhcp22.suse.cz>, <20121130032918.59B3F780@pobox.sk>, <20121130124506.GH29317@dhcp22.suse.cz>, <20121130144427.51A09169@pobox.sk> <20121130144431.GI29317@dhcp22.suse.cz>
In-Reply-To: <20121130144431.GI29317@dhcp22.suse.cz>
MIME-Version: 1.0
Message-Id: <20121130160811.6BB25BDD@pobox.sk>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?q?Michal_Hocko?= <mhocko@suse.cz>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, =?utf-8?q?cgroups_mailinglist?= <cgroups@vger.kernel.org>, =?utf-8?q?KAMEZAWA_Hiroyuki?= <kamezawa.hiroyu@jp.fujitsu.com>, =?utf-8?q?Johannes_Weiner?= <hannes@cmpxchg.org>

>DMA32 zone is usually fills up first 4G unless your HW remaps the rest
>of the memory above 4G or you have a numa machine and the rest of the
>memory is at other node. Could you post your memory map printed during
>the boot? (e820: BIOS-provided physical RAM map: and following lines)


Here is the full boot log:
www.watchdog.sk/lkml/kern.log


>You have mentioned that you are comounting with cpuset. If this happens
>to be a NUMA machine have you made the access to all nodes available?
>Also what does /proc/sys/vm/zone_reclaim_mode says?


Don't really know what NUMA means and which nodes are you talking about, sorry :(

# cat /proc/sys/vm/zone_reclaim_mode
cat: /proc/sys/vm/zone_reclaim_mode: No such file or directory



azur

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
