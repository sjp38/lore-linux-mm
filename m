Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 5E9FD6B008C
	for <linux-mm@kvack.org>; Mon, 17 Dec 2012 13:23:03 -0500 (EST)
Subject: =?utf-8?q?Re=3A_=5BPATCH_for_3=2E2=2E34=5D_memcg=3A_do_not_trigger_OOM_from_add=5Fto=5Fpage=5Fcache=5Flocked?=
Date: Mon, 17 Dec 2012 19:23:01 +0100
From: "azurIt" <azurit@pobox.sk>
References: <20121203151601.GA17093@dhcp22.suse.cz>, <20121205023644.18C3006B@pobox.sk>, <20121205141722.GA9714@dhcp22.suse.cz>, <20121206012924.FE077FD7@pobox.sk>, <20121206095423.GB10931@dhcp22.suse.cz>, <20121210022038.E6570D37@pobox.sk>, <20121210094318.GA6777@dhcp22.suse.cz>, <20121210111817.F697F53E@pobox.sk>, <20121210155205.GB6777@dhcp22.suse.cz>, <20121217023430.5A390FD7@pobox.sk> <20121217163203.GD25432@dhcp22.suse.cz>
In-Reply-To: <20121217163203.GD25432@dhcp22.suse.cz>
MIME-Version: 1.0
Message-Id: <20121217192301.829A7020@pobox.sk>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?q?Michal_Hocko?= <mhocko@suse.cz>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, =?utf-8?q?cgroups_mailinglist?= <cgroups@vger.kernel.org>, =?utf-8?q?KAMEZAWA_Hiroyuki?= <kamezawa.hiroyu@jp.fujitsu.com>, =?utf-8?q?Johannes_Weiner?= <hannes@cmpxchg.org>

>[Ohh, I am really an idiot. I screwed the first patch]
>-       bool oom = true;
>+       bool oom = !(gfp_mask | GFP_MEMCG_NO_OOM);
>
>Which obviously doesn't work. It should read !(gfp_mask &GFP_MEMCG_NO_OOM).
>  No idea how I could have missed that. I am really sorry about that.


:D no problem :) so, now it should really work as expected and completely fix my original problem? is it safe to apply it on 3.2.35? Thank you very much!

azur

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
