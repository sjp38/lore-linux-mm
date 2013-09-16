Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 1DCD46B003B
	for <linux-mm@kvack.org>; Mon, 16 Sep 2013 10:57:49 -0400 (EDT)
Date: Mon, 16 Sep 2013 16:57:44 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 0/7] improve memcg oom killer robustness v2
Message-ID: <20130916145744.GE3674@dhcp22.suse.cz>
References: <20130911180327.GL856@cmpxchg.org>
 <20130911205448.656D9D7C@pobox.sk>
 <20130911191150.GN856@cmpxchg.org>
 <20130911214118.7CDF2E71@pobox.sk>
 <20130911200426.GO856@cmpxchg.org>
 <20130914124831.4DD20346@pobox.sk>
 <20130916134014.GA3674@dhcp22.suse.cz>
 <20130916160119.2E76C2A1@pobox.sk>
 <20130916140607.GC3674@dhcp22.suse.cz>
 <20130916161316.5113F6E7@pobox.sk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130916161316.5113F6E7@pobox.sk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: azurIt <azurit@pobox.sk>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon 16-09-13 16:13:16, azurIt wrote:
[...]
> >You can use sysrq+l via serial console to see tasks hogging the CPU or
> >sysrq+t to see all the existing tasks.
> 
> 
> Doesn't work here, it just prints 'l' resp. 't'.

I am using telnet for accessing my serial consoles exported by
the multiplicator or KVM and it can send sysrq via ctrl+t (Send
Break). Check your serial console setup.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
