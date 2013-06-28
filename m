Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id CA3C06B0032
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 06:06:15 -0400 (EDT)
Subject: =?utf-8?q?Re=3A_=5BPATCH_for_3=2E2=5D_memcg=3A_do_not_trap_chargers_with_full_callstack_on_OOM?=
Date: Fri, 28 Jun 2013 12:06:13 +0200
From: "azurIt" <azurit@pobox.sk>
References: <20130210150310.GA9504@dhcp22.suse.cz>, <20130210174619.24F20488@pobox.sk>, <20130211112240.GC19922@dhcp22.suse.cz>, <20130222092332.4001E4B6@pobox.sk>, <20130606160446.GE24115@dhcp22.suse.cz>, <20130606181633.BCC3E02E@pobox.sk>, <20130607131157.GF8117@dhcp22.suse.cz>, <20130617122134.2E072BA8@pobox.sk>, <20130619132614.GC16457@dhcp22.suse.cz>, <20130622220958.D10567A4@pobox.sk> <20130624201345.GA21822@cmpxchg.org>
In-Reply-To: <20130624201345.GA21822@cmpxchg.org>
MIME-Version: 1.0
Message-Id: <20130628120613.6D6CAD21@pobox.sk>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?q?Johannes_Weiner?= <hannes@cmpxchg.org>
Cc: =?utf-8?q?Michal_Hocko?= <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, =?utf-8?q?cgroups_mailinglist?= <cgroups@vger.kernel.org>, =?utf-8?q?KAMEZAWA_Hiroyuki?= <kamezawa.hiroyu@jp.fujitsu.com>

>It's not a kernel thread that does it because all kernel-context
>handle_mm_fault() are annotated properly, which means the task must be
>userspace and, since tasks is empty, have exited before synchronizing.
>
>Can you try with the following patch on top?


Michal and Johannes,

i have some observations which i made:
Original patch from Johannes was really fixing something but definitely not everything and was introducing new problems. I'm running unpatched kernel from time i send my last message and problems with freezing cgroups are occuring very often (several times per day) - they were, on the other hand, quite rare with patch from Johannes.

Johannes, i didn't try your last patch yet. I would like to wait until you or Michal look at my last message which contained detailed information about freezing of cgroups on kernel running your original patch (which was suppose to fix it for good). Even more, i would like to hear your opinion about that stucked processes which was holding web server port and which forced me to reboot production server at the middle of the day :( more information was in my last message. Thank you very much for your time.

azur

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
