Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 31B6A6B002B
	for <linux-mm@kvack.org>; Mon, 24 Dec 2012 08:25:28 -0500 (EST)
Subject: =?utf-8?q?Re=3A_=5BPATCH_for_3=2E2=2E34=5D_memcg=3A_do_not_trigger_OOM_from_add=5Fto=5Fpage=5Fcache=5Flocked?=
Date: Mon, 24 Dec 2012 14:25:26 +0100
From: "azurIt" <azurit@pobox.sk>
References: <20121206095423.GB10931@dhcp22.suse.cz>, <20121210022038.E6570D37@pobox.sk>, <20121210094318.GA6777@dhcp22.suse.cz>, <20121210111817.F697F53E@pobox.sk>, <20121210155205.GB6777@dhcp22.suse.cz>, <20121217023430.5A390FD7@pobox.sk>, <20121217163203.GD25432@dhcp22.suse.cz>, <20121217192301.829A7020@pobox.sk>, <20121217195510.GA16375@dhcp22.suse.cz>, <20121218152223.6912832C@pobox.sk> <20121218152004.GA25208@dhcp22.suse.cz>
In-Reply-To: <20121218152004.GA25208@dhcp22.suse.cz>
MIME-Version: 1.0
Message-Id: <20121224142526.020165D3@pobox.sk>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?q?Michal_Hocko?= <mhocko@suse.cz>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, =?utf-8?q?cgroups_mailinglist?= <cgroups@vger.kernel.org>, =?utf-8?q?KAMEZAWA_Hiroyuki?= <kamezawa.hiroyu@jp.fujitsu.com>, =?utf-8?q?Johannes_Weiner?= <hannes@cmpxchg.org>

>OK, good to hear and fingers crossed. I will try to get back to the
>original problem and a better solution sometimes early next year when
>all the things settle a bit.


Michal, problem, unfortunately, happened again :( twice. When it happened first time (two days ago) i don't want to believe it so i recompiled the kernel and boot it again to be sure i really used your patch. Today it happened again, here is report:
http://watchdog.sk/lkml/memcg-bug-3.tar.gz

Here is patch which i used (kernel 3.2.35, i didn't use any other from your patches):
http://watchdog.sk/lkml/5-memcg-fix.patch

azur

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
