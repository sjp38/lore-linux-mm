Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id BF2DF6B006C
	for <linux-mm@kvack.org>; Sat, 29 Dec 2012 20:09:49 -0500 (EST)
Subject: =?utf-8?q?Re=3A_=5BPATCH_for_3=2E2=2E34=5D_memcg=3A_do_not_trigger_OOM_from_add=5Fto=5Fpage=5Fcache=5Flocked?=
Date: Sun, 30 Dec 2012 02:09:47 +0100
From: "azurIt" <azurit@pobox.sk>
References: <20121210094318.GA6777@dhcp22.suse.cz>, <20121210111817.F697F53E@pobox.sk>, <20121210155205.GB6777@dhcp22.suse.cz>, <20121217023430.5A390FD7@pobox.sk>, <20121217163203.GD25432@dhcp22.suse.cz>, <20121217192301.829A7020@pobox.sk>, <20121217195510.GA16375@dhcp22.suse.cz>, <20121218152223.6912832C@pobox.sk>, <20121218152004.GA25208@dhcp22.suse.cz>, <20121224142526.020165D3@pobox.sk> <20121228162209.GA1455@dhcp22.suse.cz>
In-Reply-To: <20121228162209.GA1455@dhcp22.suse.cz>
MIME-Version: 1.0
Message-Id: <20121230020947.AA002F34@pobox.sk>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?q?Michal_Hocko?= <mhocko@suse.cz>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, =?utf-8?q?cgroups_mailinglist?= <cgroups@vger.kernel.org>, =?utf-8?q?KAMEZAWA_Hiroyuki?= <kamezawa.hiroyu@jp.fujitsu.com>, =?utf-8?q?Johannes_Weiner?= <hannes@cmpxchg.org>

>which suggests that the patch is incomplete and that I am blind :/
>mem_cgroup_cache_charge calls __mem_cgroup_try_charge for the page cache
>and that one doesn't check GFP_MEMCG_NO_OOM. So you need the following
>follow-up patch on top of the one you already have (which should catch
>all the remaining cases).
>Sorry about that...


This was, again, killing my MySQL server (search for "(mysqld)"):
http://www.watchdog.sk/lkml/oom_mysqld5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
