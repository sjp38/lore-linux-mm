Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id B40446B0031
	for <linux-mm@kvack.org>; Thu,  5 Sep 2013 06:17:02 -0400 (EDT)
Subject: =?utf-8?q?Re=3A_=5Bpatch_0=2F7=5D_improve_memcg_oom_killer_robustness_v2?=
Date: Thu, 05 Sep 2013 12:17:00 +0200
From: "azurIt" <azurit@pobox.sk>
References: <1375549200-19110-1-git-send-email-hannes@cmpxchg.org>, <20130803170831.GB23319@cmpxchg.org>, <20130830215852.3E5D3D66@pobox.sk>, <20130902123802.5B8E8CB1@pobox.sk>, <20130903204850.GA1412@cmpxchg.org>, <20130904114523.A9F0173C@pobox.sk>, <20130904115741.GA28285@dhcp22.suse.cz>, <20130904141000.0F910EFA@pobox.sk>, <20130904122632.GB28285@dhcp22.suse.cz>, <20130905111430.CB1392B4@pobox.sk> <20130905095331.GA9702@dhcp22.suse.cz>
In-Reply-To: <20130905095331.GA9702@dhcp22.suse.cz>
MIME-Version: 1.0
Message-Id: <20130905121700.546B5881@pobox.sk>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?q?Michal_Hocko?= <mhocko@suse.cz>
Cc: =?utf-8?q?Johannes_Weiner?= <hannes@cmpxchg.org>, =?utf-8?q?Andrew_Morton?= <akpm@linux-foundation.org>, =?utf-8?q?David_Rientjes?= <rientjes@google.com>, =?utf-8?q?KAMEZAWA_Hiroyuki?= <kamezawa.hiroyu@jp.fujitsu.com>, =?utf-8?q?KOSAKI_Motohiro?= <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

>[...]
>> My script detected another freezed cgroup today, sending stacks. Is
>> there anything interesting?
>
>3 tasks are sleeping and waiting for somebody to take an action to
>resolve memcg OOM. The memcg oom killer is enabled for that group?  If
>yes, which task has been selected to be killed? You can find that in oom
>report in dmesg.
>
>I can see a way how this might happen. If the killed task happened to
>allocate a memory while it is exiting then it would get to the oom
>condition again without freeing any memory so nobody waiting on the
>memcg_oom_waitq gets woken. We have a report like that: 
>https://lkml.org/lkml/2013/7/31/94
>
>The issue got silent in the meantime so it is time to wake it up.
>It would be definitely good to see what happened in your case though.
>If any of the bellow tasks was the oom victim then it is very probable
>this is the same issue.

Here it is:
http://watchdog.sk/lkml/kern5.log

Processes were killed by my script at about 11:05:35.

azur

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
