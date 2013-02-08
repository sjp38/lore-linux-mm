Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 5460C6B0005
	for <linux-mm@kvack.org>; Fri,  8 Feb 2013 08:56:18 -0500 (EST)
Subject: =?utf-8?q?Re=3A_=5BPATCH_for_3=2E2=2E34=5D_memcg=3A_do_not_trigger_OOM_if_PF=5FNO=5FMEMCG=5FOOM_is_set?=
Date: Fri, 08 Feb 2013 14:56:16 +0100
From: "azurIt" <azurit@pobox.sk>
References: <20130205134937.GA22804@dhcp22.suse.cz>, <20130205154947.CD6411E2@pobox.sk>, <20130205160934.GB22804@dhcp22.suse.cz>, <20130206021721.1AE9E3C7@pobox.sk>, <20130206140119.GD10254@dhcp22.suse.cz>, <20130206142219.GF10254@dhcp22.suse.cz>, <20130206160051.GG10254@dhcp22.suse.cz>, <20130208060304.799F362F@pobox.sk>, <20130208094420.GA7557@dhcp22.suse.cz>, <20130208120249.FD733220@pobox.sk> <20130208123854.GB7557@dhcp22.suse.cz>
In-Reply-To: <20130208123854.GB7557@dhcp22.suse.cz>
MIME-Version: 1.0
Message-Id: <20130208145616.FB78CE24@pobox.sk>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?q?Michal_Hocko?= <mhocko@suse.cz>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, =?utf-8?q?cgroups_mailinglist?= <cgroups@vger.kernel.org>, =?utf-8?q?KAMEZAWA_Hiroyuki?= <kamezawa.hiroyu@jp.fujitsu.com>, =?utf-8?q?Johannes_Weiner?= <hannes@cmpxchg.org>

>kernel log would be sufficient.


Full kernel log from kernel with you newest patch:
http://watchdog.sk/lkml/kern2.log



>This limit is for top level groups, right? Those seem to children which
>have 62MB charged - is that a limit for those children?


It was the limit for parent cgroup and processes were in one (the same) child cgroup. Child cgroup has no memory limit set (so limit for parent was also limit for child - 330 MB).



>Which are those two processes?


Data are inside memcg-bug-5.tar.gz in directories bug/<timestamp>/<pids>/


>I have no idea what is the strace role here.


I was stracing exactly two processes from that cgroup and exactly two processes were stucked later and was immpossible to kill them. Both of them were waiting on 'ptrace_stop'. Maybe it's completely unrelated, just guessing.


azur

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
