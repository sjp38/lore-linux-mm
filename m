Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id C76D46B0032
	for <linux-mm@kvack.org>; Thu,  6 Jun 2013 12:16:35 -0400 (EDT)
Subject: =?utf-8?q?Re=3A_=5BPATCH_for_3=2E2=2E34=5D_memcg=3A_do_not_trigger_OOM_if_PF=5FNO=5FMEMCG=5FOOM_is_set?=
Date: Thu, 06 Jun 2013 18:16:33 +0200
From: "azurIt" <azurit@pobox.sk>
References: <20130208123854.GB7557@dhcp22.suse.cz>, <20130208145616.FB78CE24@pobox.sk>, <20130208152402.GD7557@dhcp22.suse.cz>, <20130208165805.8908B143@pobox.sk>, <20130208171012.GH7557@dhcp22.suse.cz>, <20130208220243.EDEE0825@pobox.sk>, <20130210150310.GA9504@dhcp22.suse.cz>, <20130210174619.24F20488@pobox.sk>, <20130211112240.GC19922@dhcp22.suse.cz>, <20130222092332.4001E4B6@pobox.sk> <20130606160446.GE24115@dhcp22.suse.cz>
In-Reply-To: <20130606160446.GE24115@dhcp22.suse.cz>
MIME-Version: 1.0
Message-Id: <20130606181633.BCC3E02E@pobox.sk>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?q?Michal_Hocko?= <mhocko@suse.cz>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, =?utf-8?q?cgroups_mailinglist?= <cgroups@vger.kernel.org>, =?utf-8?q?KAMEZAWA_Hiroyuki?= <kamezawa.hiroyu@jp.fujitsu.com>, =?utf-8?q?Johannes_Weiner?= <hannes@cmpxchg.org>

Hello Michal,

nice to read you! :) Yes, i'm still on 3.2. Could you be so kind and try to backport it? Thank you very much!

azur



______________________________________________________________
> Od: "Michal Hocko" <mhocko@suse.cz>
> Komu: azurIt <azurit@pobox.sk>
> DA!tum: 06.06.2013 18:04
> Predmet: Re: [PATCH for 3.2.34] memcg: do not trigger OOM if PF_NO_MEMCG_OOM is set
>
> CC: linux-kernel@vger.kernel.org, linux-mm@kvack.org, "cgroups mailinglist" <cgroups@vger.kernel.org>, "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>, "Johannes Weiner" <hannes@cmpxchg.org>
>Hi,
>
>I am really sorry it took so long but I was constantly preempted by
>other stuff. I hope I have a good news for you, though. Johannes has
>found a nice way how to overcome deadlock issues from memcg OOM which
>might help you. Would you be willing to test with his patch
>(http://permalink.gmane.org/gmane.linux.kernel.mm/101437). Unlike my
>patch which handles just the i_mutex case his patch solved all possible
>locks.
>
>I can backport the patch for your kernel (are you still using 3.2 kernel
>or you have moved to a newer one?).
>
>On Fri 22-02-13 09:23:32, azurIt wrote:
>> >Unfortunately I am not able to reproduce this behavior even if I try
>> >to hammer OOM like mad so I am afraid I cannot help you much without
>> >further debugging patches.
>> >I do realize that experimenting in your environment is a problem but I
>> >do not many options left. Please do not use strace and rather collect
>> >/proc/pid/stack instead. It would be also helpful to get group/tasks
>> >file to have a full list of tasks in the group
>> 
>> 
>> 
>> Hi Michal,
>> 
>> 
>> sorry that i didn't response for a while. Today i installed kernel with your two patches and i'm running it now. I'm still having problems with OOM which is not able to handle low memory and is not killing processes. Here is some info:
>> 
>> - data from cgroup 1258 while it was under OOM and no processes were killed (so OOM don't stop and cgroup was freezed)
>> http://watchdog.sk/lkml/memcg-bug-6.tar.gz
>> 
>> I noticed problem about on 8:39 and waited until 8:57 (nothing happend). Then i killed process 19864 which seems to help and other processes probably ends and cgroup started to work. But problem accoured again about 20 seconds later, so i killed all processes at 8:58. The problem is occuring all the time since then. All processes (in that cgroup) are always in state 'D' when it occurs.
>> 
>> 
>> - kernel log from boot until now
>> http://watchdog.sk/lkml/kern3.gz
>> 
>> 
>> Btw, something probably happened also at about 3:09 but i wasn't able to gather any data because my 'load check script' killed all apache processes (load was more than 100).
>> 
>> 
>> 
>> azur
>> --
>> To unsubscribe from this list: send the line "unsubscribe cgroups" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>-- 
>Michal Hocko
>SUSE Labs
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
