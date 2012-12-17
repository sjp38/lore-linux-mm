Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 3BD2F6B002B
	for <linux-mm@kvack.org>; Sun, 16 Dec 2012 20:34:33 -0500 (EST)
Subject: =?utf-8?q?Re=3A_=5BPATCH_for_3=2E2=2E34=5D_memcg=3A_do_not_trigger_OOM_from_add=5Fto=5Fpage=5Fcache=5Flocked?=
Date: Mon, 17 Dec 2012 02:34:30 +0100
From: "azurIt" <azurit@pobox.sk>
References: <20121130165937.F9564EBE@pobox.sk>, <20121130161923.GN29317@dhcp22.suse.cz>, <20121203151601.GA17093@dhcp22.suse.cz>, <20121205023644.18C3006B@pobox.sk>, <20121205141722.GA9714@dhcp22.suse.cz>, <20121206012924.FE077FD7@pobox.sk>, <20121206095423.GB10931@dhcp22.suse.cz>, <20121210022038.E6570D37@pobox.sk>, <20121210094318.GA6777@dhcp22.suse.cz>, <20121210111817.F697F53E@pobox.sk> <20121210155205.GB6777@dhcp22.suse.cz>
In-Reply-To: <20121210155205.GB6777@dhcp22.suse.cz>
MIME-Version: 1.0
Message-Id: <20121217023430.5A390FD7@pobox.sk>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?q?Michal_Hocko?= <mhocko@suse.cz>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, =?utf-8?q?cgroups_mailinglist?= <cgroups@vger.kernel.org>, =?utf-8?q?KAMEZAWA_Hiroyuki?= <kamezawa.hiroyu@jp.fujitsu.com>, =?utf-8?q?Johannes_Weiner?= <hannes@cmpxchg.org>

>I would try to limit changes to minimum. So the original kernel you were
>using + the first patch to prevent OOM from the write path + 2 debugging
>patches.


It didn't take off the whole system this time (but i was prepared to record a video of console ;) ), here it is:
http://www.watchdog.sk/lkml/oom_mysqld4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
