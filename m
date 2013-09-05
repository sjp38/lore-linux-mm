Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 7F9076B0031
	for <linux-mm@kvack.org>; Thu,  5 Sep 2013 09:00:46 -0400 (EDT)
Subject: =?utf-8?q?Re=3A_=5Bpatch_0=2F7=5D_improve_memcg_oom_killer_robustness_v2?=
Date: Thu, 05 Sep 2013 15:00:44 +0200
From: "azurIt" <azurit@pobox.sk>
References: <20130904115741.GA28285@dhcp22.suse.cz>, <20130904141000.0F910EFA@pobox.sk>, <20130904122632.GB28285@dhcp22.suse.cz>, <20130905111430.CB1392B4@pobox.sk>, <20130905095331.GA9702@dhcp22.suse.cz>, <20130905121700.546B5881@pobox.sk>, <20130905111742.GC9702@dhcp22.suse.cz>, <20130905134702.C703F65B@pobox.sk>, <20130905120347.GA13666@dhcp22.suse.cz>, <20130905143343.AF56A889@pobox.sk> <20130905124523.GC13666@dhcp22.suse.cz>
In-Reply-To: <20130905124523.GC13666@dhcp22.suse.cz>
MIME-Version: 1.0
Message-Id: <20130905150044.ED46FBDF@pobox.sk>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?q?Michal_Hocko?= <mhocko@suse.cz>
Cc: =?utf-8?q?Johannes_Weiner?= <hannes@cmpxchg.org>, =?utf-8?q?Andrew_Morton?= <akpm@linux-foundation.org>, =?utf-8?q?David_Rientjes?= <rientjes@google.com>, =?utf-8?q?KAMEZAWA_Hiroyuki?= <kamezawa.hiroyu@jp.fujitsu.com>, =?utf-8?q?KOSAKI_Motohiro?= <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

>On Thu 05-09-13 14:33:43, azurIt wrote:
>[...]
>> >Just to be sure I got you right. You have killed all the processes from
>> >the group you have sent stacks for, right? If that is the case I am
>> >really curious about processes sitting in sleep_on_page_killable because
>> >those are killable by definition.
>> 
>> Yes, my script killed all of that processes right after taking
>> stack.
>
>OK, _after_ part is important. Has the group gone away after then?



If you mean if it wasn't making problems after killing it's processes, then yes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
