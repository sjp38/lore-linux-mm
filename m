Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 5A7256B0044
	for <linux-mm@kvack.org>; Tue,  4 Dec 2012 20:36:46 -0500 (EST)
Subject: =?utf-8?q?Re=3A_=5BPATCH_for_3=2E2=2E34=5D_memcg=3A_do_not_trigger_OOM_from_add=5Fto=5Fpage=5Fcache=5Flocked?=
Date: Wed, 05 Dec 2012 02:36:44 +0100
From: "azurIt" <azurit@pobox.sk>
References: <20121126131837.GC17860@dhcp22.suse.cz>, <20121126132149.GD17860@dhcp22.suse.cz>, <20121130032918.59B3F780@pobox.sk>, <20121130124506.GH29317@dhcp22.suse.cz>, <20121130144427.51A09169@pobox.sk>, <20121130144431.GI29317@dhcp22.suse.cz>, <20121130160811.6BB25BDD@pobox.sk>, <20121130153942.GL29317@dhcp22.suse.cz>, <20121130165937.F9564EBE@pobox.sk>, <20121130161923.GN29317@dhcp22.suse.cz> <20121203151601.GA17093@dhcp22.suse.cz>
In-Reply-To: <20121203151601.GA17093@dhcp22.suse.cz>
MIME-Version: 1.0
Message-Id: <20121205023644.18C3006B@pobox.sk>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?q?Michal_Hocko?= <mhocko@suse.cz>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, =?utf-8?q?cgroups_mailinglist?= <cgroups@vger.kernel.org>, =?utf-8?q?KAMEZAWA_Hiroyuki?= <kamezawa.hiroyu@jp.fujitsu.com>, =?utf-8?q?Johannes_Weiner?= <hannes@cmpxchg.org>

>The following should print the traces when we hand over ENOMEM to the
>caller. It should catch all charge paths (migration is not covered but
>that one is not important here). If we don't see any traces from here
>and there is still global OOM striking then there must be something else
>to trigger this.
>Could you test this with the patch which aims at fixing your deadlock,
>please? I realise that this is a production environment but I do not see
>anything relevant in the code.


Michal,

i think/hope this is what you wanted:
http://www.watchdog.sk/lkml/oom_mysqld2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
