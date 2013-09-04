Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id EE2666B0032
	for <linux-mm@kvack.org>; Wed,  4 Sep 2013 07:57:44 -0400 (EDT)
Date: Wed, 4 Sep 2013 13:57:41 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 0/7] improve memcg oom killer robustness v2
Message-ID: <20130904115741.GA28285@dhcp22.suse.cz>
References: <1375549200-19110-1-git-send-email-hannes@cmpxchg.org>
 <20130803170831.GB23319@cmpxchg.org>
 <20130830215852.3E5D3D66@pobox.sk>
 <20130902123802.5B8E8CB1@pobox.sk>
 <20130903204850.GA1412@cmpxchg.org>
 <20130904114523.A9F0173C@pobox.sk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130904114523.A9F0173C@pobox.sk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: azurIt <azurit@pobox.sk>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 04-09-13 11:45:23, azurIt wrote:
[...]
> My script has just detected (and killed) another freezed cgroup. I
> must say that i'm not 100% sure that cgroup was really freezed but it
> has 99% or more memory usage for at least 30 seconds (well, or it has
> 99% memory usage in both two cases the script was checking it). Here
> are stacks of processes inside it before they were killed:
[...]
> pid: 26536
> stack:
> [<ffffffff81080a45>] refrigerator+0x95/0x160
> [<ffffffff8106ac2b>] get_signal_to_deliver+0x1cb/0x540
> [<ffffffff8100188b>] do_signal+0x6b/0x750
> [<ffffffff81001fc5>] do_notify_resume+0x55/0x80
> [<ffffffff815cb662>] retint_signal+0x3d/0x7b
> [<ffffffffffffffff>] 0xffffffffffffffff

[...]

This task is sitting in the refigerator which means it has been frozen
by the freezer cgroup most probably. I am not familiar with the
implementation but my recollection is that you have to thaw that group
in order the killed process can pass away.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
