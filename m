Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 07A0A6B0036
	for <linux-mm@kvack.org>; Sat, 22 Jun 2013 16:10:00 -0400 (EDT)
Subject: =?utf-8?q?Re=3A_=5BPATCH_for_3=2E2=5D_memcg=3A_do_not_trap_chargers_with_full_callstack_on_OOM?=
Date: Sat, 22 Jun 2013 22:09:58 +0200
From: "azurIt" <azurit@pobox.sk>
References: <20130208171012.GH7557@dhcp22.suse.cz>, <20130208220243.EDEE0825@pobox.sk>, <20130210150310.GA9504@dhcp22.suse.cz>, <20130210174619.24F20488@pobox.sk>, <20130211112240.GC19922@dhcp22.suse.cz>, <20130222092332.4001E4B6@pobox.sk>, <20130606160446.GE24115@dhcp22.suse.cz>, <20130606181633.BCC3E02E@pobox.sk>, <20130607131157.GF8117@dhcp22.suse.cz>, <20130617122134.2E072BA8@pobox.sk> <20130619132614.GC16457@dhcp22.suse.cz>
In-Reply-To: <20130619132614.GC16457@dhcp22.suse.cz>
MIME-Version: 1.0
Message-Id: <20130622220958.D10567A4@pobox.sk>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?q?Michal_Hocko?= <mhocko@suse.cz>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, =?utf-8?q?cgroups_mailinglist?= <cgroups@vger.kernel.org>, =?utf-8?q?KAMEZAWA_Hiroyuki?= <kamezawa.hiroyu@jp.fujitsu.com>, =?utf-8?q?Johannes_Weiner?= <hannes@cmpxchg.org>

Michal,



>> I'm unable to send you stacks or more info because problem is taking
>> down the whole server for some time now (don't know what exactly
>> caused it to start happening, maybe newer versions of 3.2.x).
>
>So you are not testing with the same kernel with just the old patch
>replaced by the new one?


No, i'm not testing with the same kernel but all are 3.2.x. I even cannot install older 3.2.x because grsecurity is always available for newest kernel and there is no archive of older versions (at least i don't know about any).


>> But i'm sure of one thing - when problem occurs, nothing is able to
>> access hard drives (every process which tries it is freezed until
>> problem is resolved or server is rebooted).
>
>I would be really interesting to see what those tasks are blocked on.


I'm trying to get it, stay tuned :)


Today i noticed one bug, not 100% sure it is related to 'your' patch but i didn't seen this before. I noticed that i have lots of cgroups which cannot be removed - if i do 'rmdir <cgroup_directory>', it just hangs and never complete. Even more, it's not possible to access the whole cgroup filesystem until i kill that rmdir (anything, which tries it, just hangs). All unremoveable cgroups has this in 'memory.oom_control':
oom_kill_disable 0
under_oom 1

And, yes, 'tasks' file is empty.

azur

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
