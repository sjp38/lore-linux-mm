Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id A8B496B0062
	for <linux-mm@kvack.org>; Mon, 16 Sep 2013 11:24:07 -0400 (EDT)
Subject: =?utf-8?q?Re=3A_=5Bpatch_0=2F7=5D_improve_memcg_oom_killer_robustness_v2?=
Date: Mon, 16 Sep 2013 17:24:05 +0200
From: "azurIt" <azurit@pobox.sk>
References: <20130911191150.GN856@cmpxchg.org>, <20130911214118.7CDF2E71@pobox.sk>, <20130911200426.GO856@cmpxchg.org>, <20130914124831.4DD20346@pobox.sk>, <20130916134014.GA3674@dhcp22.suse.cz>, <20130916160119.2E76C2A1@pobox.sk>, <20130916140607.GC3674@dhcp22.suse.cz>, <20130916161316.5113F6E7@pobox.sk>, <20130916145744.GE3674@dhcp22.suse.cz>, <20130916170543.77F1ECB4@pobox.sk> <20130916151726.GY856@cmpxchg.org>
In-Reply-To: <20130916151726.GY856@cmpxchg.org>
MIME-Version: 1.0
Message-Id: <20130916172405.740B7FBD@pobox.sk>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?q?Johannes_Weiner?= <hannes@cmpxchg.org>
Cc: =?utf-8?q?Michal_Hocko?= <mhocko@suse.cz>, =?utf-8?q?Andrew_Morton?= <akpm@linux-foundation.org>, =?utf-8?q?David_Rientjes?= <rientjes@google.com>, =?utf-8?q?KAMEZAWA_Hiroyuki?= <kamezawa.hiroyu@jp.fujitsu.com>, =?utf-8?q?KOSAKI_Motohiro?= <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

> CC: "Michal Hocko" <mhocko@suse.cz>, "Andrew Morton" <akpm@linux-foundation.org>, "David Rientjes" <rientjes@google.com>, "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>, "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org
>On Mon, Sep 16, 2013 at 05:05:43PM +0200, azurIt wrote:
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
>> I'm using Raritan KVM and i created keyboard macro 'sysrq + l' resp. 'sysrq + t'. I'm also unable to use it on my local PC. Maybe it needs to be enabled somehow?
>
>Can you 'echo t >/proc/sysrq-trigger'?



# ls -la /proc/sysrq-trigger
ls: cannot access /proc/sysrq-trigger: No such file or directory

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
