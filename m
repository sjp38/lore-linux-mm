Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 31D9A6B0033
	for <linux-mm@kvack.org>; Thu,  5 Sep 2013 05:14:33 -0400 (EDT)
Subject: =?utf-8?q?Re=3A_=5Bpatch_0=2F7=5D_improve_memcg_oom_killer_robustness_v2?=
Date: Thu, 05 Sep 2013 11:14:30 +0200
From: "azurIt" <azurit@pobox.sk>
References: <1375549200-19110-1-git-send-email-hannes@cmpxchg.org>, <20130803170831.GB23319@cmpxchg.org>, <20130830215852.3E5D3D66@pobox.sk>, <20130902123802.5B8E8CB1@pobox.sk>, <20130903204850.GA1412@cmpxchg.org>, <20130904114523.A9F0173C@pobox.sk>, <20130904115741.GA28285@dhcp22.suse.cz>, <20130904141000.0F910EFA@pobox.sk> <20130904122632.GB28285@dhcp22.suse.cz>
In-Reply-To: <20130904122632.GB28285@dhcp22.suse.cz>
MIME-Version: 1.0
Message-Id: <20130905111430.CB1392B4@pobox.sk>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?q?Michal_Hocko?= <mhocko@suse.cz>
Cc: =?utf-8?q?Johannes_Weiner?= <hannes@cmpxchg.org>, =?utf-8?q?Andrew_Morton?= <akpm@linux-foundation.org>, =?utf-8?q?David_Rientjes?= <rientjes@google.com>, =?utf-8?q?KAMEZAWA_Hiroyuki?= <kamezawa.hiroyu@jp.fujitsu.com>, =?utf-8?q?KOSAKI_Motohiro?= <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

>> >[...]
>> >> My script has just detected (and killed) another freezed cgroup. I
>> >> must say that i'm not 100% sure that cgroup was really freezed but it
>> >> has 99% or more memory usage for at least 30 seconds (well, or it has
>> >> 99% memory usage in both two cases the script was checking it). Here
>> >> are stacks of processes inside it before they were killed:
>> >[...]
>> >> pid: 26536
>> >> stack:
>> >> [<ffffffff81080a45>] refrigerator+0x95/0x160
>> >> [<ffffffff8106ac2b>] get_signal_to_deliver+0x1cb/0x540
>> >> [<ffffffff8100188b>] do_signal+0x6b/0x750
>> >> [<ffffffff81001fc5>] do_notify_resume+0x55/0x80
>> >> [<ffffffff815cb662>] retint_signal+0x3d/0x7b
>> >> [<ffffffffffffffff>] 0xffffffffffffffff
>> >
>> >[...]
>> >
>> >This task is sitting in the refigerator which means it has been frozen
>> >by the freezer cgroup most probably. I am not familiar with the
>> >implementation but my recollection is that you have to thaw that group
>> >in order the killed process can pass away.
>> 
>> Yes, my script is freezing the cgroup before killing processes inside
>> it. Stacks are taken after the freeze, it that problem?
>
>I thought you had a problem to remove this particular group...
>-- 
>Michal Hocko
>SUSE Labs




My script detected another freezed cgroup today, sending stacks. Is there anything interesting?



pid: 947
stack:
[<ffffffff810ceefe>] sleep_on_page_killable+0xe/0x40
[<ffffffff810cee57>] __lock_page_killable+0x67/0x70
[<ffffffff810d1067>] generic_file_aio_read+0x4d7/0x790
[<ffffffff81116a8a>] do_sync_read+0xea/0x130
[<ffffffff81117a40>] vfs_read+0xf0/0x220
[<ffffffff81117c71>] sys_read+0x51/0x90
[<ffffffff815cbce6>] system_call_fastpath+0x18/0x1d
[<ffffffffffffffff>] 0xffffffffffffffff


pid: 949
stack:
[<ffffffff810ceefe>] sleep_on_page_killable+0xe/0x40
[<ffffffff810cee57>] __lock_page_killable+0x67/0x70
[<ffffffff810d1067>] generic_file_aio_read+0x4d7/0x790
[<ffffffff81116a8a>] do_sync_read+0xea/0x130
[<ffffffff81117a40>] vfs_read+0xf0/0x220
[<ffffffff81117c71>] sys_read+0x51/0x90
[<ffffffff815cbce6>] system_call_fastpath+0x18/0x1d
[<ffffffffffffffff>] 0xffffffffffffffff


pid: 985
stack:
[<ffffffff810ceefe>] sleep_on_page_killable+0xe/0x40
n[<ffffffff810cee57>] __lock_page_killable+0x67/0x70
[<ffffffff810d1067>] generic_file_aio_read+0x4d7/0x790
[<ffffffff81116a8a>] do_sync_read+0xea/0x130
[<ffffffff81117a40>] vfs_read+0xf0/0x220
[<ffffffff81117c71>] sys_read+0x51/0x90
[<ffffffff815cbce6>] system_call_fastpath+0x18/0x1d
[<ffffffffffffffff>] 0xffffffffffffffff


pid: 987
stack:
[<ffffffff810ceefe>] sleep_on_page_killable+0xe/0x40
[<ffffffff810cee57>] __lock_page_killable+0x67/0x70
[<ffffffff810d1067>] generic_file_aio_read+0x4d7/0x790
[<ffffffff81116a8a>] do_sync_read+0xea/0x130
[<ffffffff81117a40>] vfs_read+0xf0/0x220
[<ffffffff81117c71>] sys_read+0x51/0x90
[<ffffffff815cbce6>] system_call_fastpath+0x18/0x1d
[<ffffffffffffffff>] 0xffffffffffffffff


pid: 1031
stack:
[<ffffffff8110f255>] mem_cgroup_oom_synchronize+0x165/0x190
[<ffffffff810d269e>] pagefault_out_of_memory+0xe/0x120
[<ffffffff81026f5e>] mm_fault_error+0x9e/0x150
[<ffffffff81027414>] do_page_fault+0x404/0x490
[<ffffffff815cb7bf>] page_fault+0x1f/0x30
[<ffffffffffffffff>] 0xffffffffffffffff


pid: 1032
stack:
[<ffffffffffffffff>] 0xffffffffffffffff


pid: 1036
stack:
[<ffffffff8110f255>] mem_cgroup_oom_synchronize+0x165/0x190
[<ffffffff810d269e>] pagefault_out_of_memory+0xe/0x120
[<ffffffff81026f5e>] mm_fault_error+0x9e/0x150
[<ffffffff81027414>] do_page_fault+0x404/0x490
[<ffffffff815cb7bf>] page_fault+0x1f/0x30
[<ffffffffffffffff>] 0xffffffffffffffff


pid: 1038
stack:
[<ffffffff8110f255>] mem_cgroup_oom_synchronize+0x165/0x190
[<ffffffff810d269e>] pagefault_out_of_memory+0xe/0x120
[<ffffffff81026f5e>] mm_fault_error+0x9e/0x150
[<ffffffff81027414>] do_page_fault+0x404/0x490
[<ffffffff815cb7bf>] page_fault+0x1f/0x30
[<ffffffffffffffff>] 0xffffffffffffffff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
