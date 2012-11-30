Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 9D1646B00A2
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 07:53:32 -0500 (EST)
Subject: =?utf-8?q?Re=3A_=5BPATCH_for_3=2E2=2E34=5D_memcg=3A_do_not_trigger_OOM_from_add=5Fto=5Fpage=5Fcache=5Flocked?=
Date: Fri, 30 Nov 2012 13:53:30 +0100
From: "azurIt" <azurit@pobox.sk>
References: <20121123074023.GA24698@dhcp22.suse.cz>, <20121123102137.10D6D653@pobox.sk>, <20121123100438.GF24698@dhcp22.suse.cz>, <20121125011047.7477BB5E@pobox.sk>, <20121125120524.GB10623@dhcp22.suse.cz>, <20121125135542.GE10623@dhcp22.suse.cz>, <20121126013855.AF118F5E@pobox.sk>, <20121126131837.GC17860@dhcp22.suse.cz>, <20121126132149.GD17860@dhcp22.suse.cz>, <20121130032918.59B3F780@pobox.sk> <20121130124506.GH29317@dhcp22.suse.cz>
In-Reply-To: <20121130124506.GH29317@dhcp22.suse.cz>
MIME-Version: 1.0
Message-Id: <20121130135330.6D012B71@pobox.sk>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?q?Michal_Hocko?= <mhocko@suse.cz>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, =?utf-8?q?cgroups_mailinglist?= <cgroups@vger.kernel.org>, =?utf-8?q?KAMEZAWA_Hiroyuki?= <kamezawa.hiroyu@jp.fujitsu.com>, =?utf-8?q?Johannes_Weiner?= <hannes@cmpxchg.org>

>Anyway your system is under both global and local memory pressure. You
>didn't see apache going down previously because it was probably the one
>which was stuck and could be killed.
>Anyway you need to setup your system more carefully.


No, it wasn't, i'm 1000% sure (i was on SSH). Here is the memory usage graph from that system on that time:
http://www.watchdog.sk/lkml/memory.png

The blank part is rebooting into new kernel. MySQL server was killed several times, then i rebooted into previous kernel and problem was gone (not a single MySQL kill). You can see two MySQL kills there on 03:54 and 03:04:30.


>
>> Maybe i should mention that MySQL server has it's own cgroup (called
>> 'mysql') but with no limits to any resources.
>
>Where is that group in the hierarchy?



In root.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
