Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id E15F66B0002
	for <linux-mm@kvack.org>; Tue,  5 Feb 2013 09:49:49 -0500 (EST)
Subject: =?utf-8?q?Re=3A_=5BPATCH_for_3=2E2=2E34=5D_memcg=3A_do_not_trigger_OOM_from_add=5Fto=5Fpage=5Fcache=5Flocked?=
Date: Tue, 05 Feb 2013 15:49:47 +0100
From: "azurIt" <azurit@pobox.sk>
References: <20121217192301.829A7020@pobox.sk>, <20121217195510.GA16375@dhcp22.suse.cz>, <20121218152223.6912832C@pobox.sk>, <20121218152004.GA25208@dhcp22.suse.cz>, <20121224142526.020165D3@pobox.sk>, <20121228162209.GA1455@dhcp22.suse.cz>, <20121230020947.AA002F34@pobox.sk>, <20121230110815.GA12940@dhcp22.suse.cz>, <20130125160723.FAE73567@pobox.sk>, <20130125163130.GF4721@dhcp22.suse.cz> <20130205134937.GA22804@dhcp22.suse.cz>
In-Reply-To: <20130205134937.GA22804@dhcp22.suse.cz>
MIME-Version: 1.0
Message-Id: <20130205154947.CD6411E2@pobox.sk>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?q?Michal_Hocko?= <mhocko@suse.cz>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, =?utf-8?q?cgroups_mailinglist?= <cgroups@vger.kernel.org>, =?utf-8?q?KAMEZAWA_Hiroyuki?= <kamezawa.hiroyu@jp.fujitsu.com>, =?utf-8?q?Johannes_Weiner?= <hannes@cmpxchg.org>

>Sorry, to get back to this that late but I was busy as hell since the
>beginning of the year.


Thank you for your time!


>Has the issue repeated since then?


Yes, it's happening all the time but meanwhile i wrote a script which is monitoring the problem and killing freezed processes when it occurs. But i don't like it much, it's not a solution for me :( i also noticed, that problem is always affecting the whole server but not so much as freezed cgroup. Depends on number of freezed processes, sometimes it has almost no imapct on the rest of the server, sometimes the whole server is lagging much.

I have another old problem which is maybe also related to this. I wasn't connecting it with this before but now i'm not sure. Two of our servers, which are affected by this cgroup problem, are also randomly freezing completely (few times per month). These are the symptoms:
 - servers are answering to ping
 - it is possible to connect via SSH but connection is freezed after sending the password
 - it is possible to login via console but it is freezed after typeing the login
These symptoms are very similar to HDD problems or HDD overload (but there is no overload for sure). The only way to fix it is, probably, hard rebooting the server (didn't find any other way). What do you think? Can this be related? Maybe HDDs are locked in the similar way the cgroups are - we already found out that cgroup freezeing is related also to HDD activity. Maybe there is a little chance that the whole HDD subsystem ends in deadlock?


>You said you didn't apply other than the above mentioned patch. Could
>you apply also debugging part of the patches I have sent?
>In case you don't have it handy then it should be this one:


Just to be sure - am i supposed to apply this two patches?
http://watchdog.sk/lkml/patches/


azur

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
