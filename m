Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 958546B0032
	for <linux-mm@kvack.org>; Mon, 16 Sep 2013 16:52:48 -0400 (EDT)
Subject: =?utf-8?q?Re=3A_=5Bpatch_0=2F7=5D_improve_memcg_oom_killer_robustness_v2?=
Date: Mon, 16 Sep 2013 22:52:46 +0200
From: "azurIt" <azurit@pobox.sk>
References: <20130911191150.GN856@cmpxchg.org>, <20130911214118.7CDF2E71@pobox.sk>, <20130911200426.GO856@cmpxchg.org>, <20130914124831.4DD20346@pobox.sk>, <20130916134014.GA3674@dhcp22.suse.cz>, <20130916160119.2E76C2A1@pobox.sk>, <20130916140607.GC3674@dhcp22.suse.cz>, <20130916161316.5113F6E7@pobox.sk>, <20130916145744.GE3674@dhcp22.suse.cz>, <20130916170543.77F1ECB4@pobox.sk> <20130916152548.GF3674@dhcp22.suse.cz>
In-Reply-To: <20130916152548.GF3674@dhcp22.suse.cz>
MIME-Version: 1.0
Message-Id: <20130916225246.A633145B@pobox.sk>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?q?Michal_Hocko?= <mhocko@suse.cz>
Cc: =?utf-8?q?Johannes_Weiner?= <hannes@cmpxchg.org>, =?utf-8?q?Andrew_Morton?= <akpm@linux-foundation.org>, =?utf-8?q?David_Rientjes?= <rientjes@google.com>, =?utf-8?q?KAMEZAWA_Hiroyuki?= <kamezawa.hiroyu@jp.fujitsu.com>, =?utf-8?q?KOSAKI_Motohiro?= <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

> CC: "Johannes Weiner" <hannes@cmpxchg.org>, "Andrew Morton" <akpm@linux-foundation.org>, "David Rientjes" <rientjes@google.com>, "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>, "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org
>On Mon 16-09-13 17:05:43, azurIt wrote:
>> > CC: "Johannes Weiner" <hannes@cmpxchg.org>, "Andrew Morton" <akpm@linux-foundation.org>, "David Rientjes" <rientjes@google.com>, "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>, "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org
>> >On Mon 16-09-13 16:13:16, azurIt wrote:
>> >[...]
>> >> >You can use sysrq+l via serial console to see tasks hogging the CPU or
>> >> >sysrq+t to see all the existing tasks.
>> >> 
>> >> 
>> >> Doesn't work here, it just prints 'l' resp. 't'.
>> >
>> >I am using telnet for accessing my serial consoles exported by
>> >the multiplicator or KVM and it can send sysrq via ctrl+t (Send
>> >Break). Check your serial console setup.
>> 
>> 
>> 
>> I'm using Raritan KVM and i created keyboard macro 'sysrq + l' resp.
>> 'sysrq + t'. I'm also unable to use it on my local PC. Maybe it needs
>> to be enabled somehow?
>
>Probably yes. echo 1 > /proc/sys/kernel/sysrq should enable all sysrq
>commands. You can select also some of them (have a look at
>Documentation/sysrq.txt for more information)


Now it happens again and i was just looking on the server's htop. I'm sure that this time it was only one process (apache) running under user account (not root). It was taking about 100% CPU (about 100% of one core). I was able to kill it by hand inside htop but everything was very slow, server load was immediately on 500. I'm sure it must be related to that Johannes kernel patches because i'm also using i/o throttling in cgroups via Block IO controller so users are unable to create such a huge I/O. I will try to take stacks of processes but i'm not able to identify the problematic process so i will have to take them from *all* apache processes while killing them.

azur

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
