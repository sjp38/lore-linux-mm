Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 799C56B0032
	for <linux-mm@kvack.org>; Mon, 24 Jun 2013 12:48:42 -0400 (EDT)
Subject: =?utf-8?q?Re=3A_=5BPATCH_for_3=2E2=5D_memcg=3A_do_not_trap_chargers_with_full_callstack_on_OOM?=
Date: Mon, 24 Jun 2013 18:48:40 +0200
From: "azurIt" <azurit@pobox.sk>
References: <20130208171012.GH7557@dhcp22.suse.cz>, <20130208220243.EDEE0825@pobox.sk>, <20130210150310.GA9504@dhcp22.suse.cz>, <20130210174619.24F20488@pobox.sk>, <20130211112240.GC19922@dhcp22.suse.cz>, <20130222092332.4001E4B6@pobox.sk>, <20130606160446.GE24115@dhcp22.suse.cz>, <20130606181633.BCC3E02E@pobox.sk>, <20130607131157.GF8117@dhcp22.suse.cz>, <20130617122134.2E072BA8@pobox.sk> <20130619132614.GC16457@dhcp22.suse.cz>
In-Reply-To: <20130619132614.GC16457@dhcp22.suse.cz>
MIME-Version: 1.0
Message-Id: <20130624184840.781777E6@pobox.sk>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?q?Michal_Hocko?= <mhocko@suse.cz>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, =?utf-8?q?cgroups_mailinglist?= <cgroups@vger.kernel.org>, =?utf-8?q?KAMEZAWA_Hiroyuki?= <kamezawa.hiroyu@jp.fujitsu.com>, =?utf-8?q?Johannes_Weiner?= <hannes@cmpxchg.org>

>I would be really interesting to see what those tasks are blocked on.


Ok, i got it! Problem occurs two times and it behaves differently each time, I was running kernel with that latest patch.

1.) It doesn't have impact on the whole server, only on one cgroup. Here are stacks:
http://watchdog.sk/lkml/memcg-bug-7.tar.gz


2.) It almost takes down the server because of huge I/O on HDDs. Unfortunately, i had a bug in my script which was suppose to gather stacks (i wasn't able to do it by hand like in (1), server was almost unoperable). But I was lucky and somehow killed processes from problematic cgroup (via htop) and server was ok again EXCEPT one important thing - processes from that cgroup were still running in D state and i wasn't able to kill them for good. They were taking web server network ports so i had to reboot the server :( BUT, before that, i gathered stacks:
http://watchdog.sk/lkml/memcg-bug-8.tar.gz

What do you think?

azur

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
