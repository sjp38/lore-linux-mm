Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 7ED026B0068
	for <linux-mm@kvack.org>; Thu, 29 Nov 2012 21:29:20 -0500 (EST)
Subject: =?utf-8?q?Re=3A_=5BPATCH_for_3=2E2=2E34=5D_memcg=3A_do_not_trigger_OOM_from_add=5Fto=5Fpage=5Fcache=5Flocked?=
Date: Fri, 30 Nov 2012 03:29:18 +0100
From: "azurIt" <azurit@pobox.sk>
References: <20121122214249.GA20319@dhcp22.suse.cz>, <20121122233434.3D5E35E6@pobox.sk>, <20121123074023.GA24698@dhcp22.suse.cz>, <20121123102137.10D6D653@pobox.sk>, <20121123100438.GF24698@dhcp22.suse.cz>, <20121125011047.7477BB5E@pobox.sk>, <20121125120524.GB10623@dhcp22.suse.cz>, <20121125135542.GE10623@dhcp22.suse.cz>, <20121126013855.AF118F5E@pobox.sk>, <20121126131837.GC17860@dhcp22.suse.cz> <20121126132149.GD17860@dhcp22.suse.cz>
In-Reply-To: <20121126132149.GD17860@dhcp22.suse.cz>
MIME-Version: 1.0
Message-Id: <20121130032918.59B3F780@pobox.sk>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?q?Michal_Hocko?= <mhocko@suse.cz>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, =?utf-8?q?cgroups_mailinglist?= <cgroups@vger.kernel.org>, =?utf-8?q?KAMEZAWA_Hiroyuki?= <kamezawa.hiroyu@jp.fujitsu.com>, =?utf-8?q?Johannes_Weiner?= <hannes@cmpxchg.org>

>Here we go with the patch for 3.2.34. Could you test with this one,
>please?


Michal, unfortunately i had to boot to another kernel because the one with this patch keeps killing my MySQL server :( it was, probably, doing it on OOM in any cgroup - looks like OOM was not choosing processes only from cgroup which is out of memory. Here is the log from syslog: http://www.watchdog.sk/lkml/oom_mysqld

Maybe i should mention that MySQL server has it's own cgroup (called 'mysql') but with no limits to any resources.

azurIt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
