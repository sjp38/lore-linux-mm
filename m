Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 151986B0032
	for <linux-mm@kvack.org>; Tue,  3 Sep 2013 16:49:02 -0400 (EDT)
Date: Tue, 3 Sep 2013 16:48:50 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 0/7] improve memcg oom killer robustness v2
Message-ID: <20130903204850.GA1412@cmpxchg.org>
References: <1375549200-19110-1-git-send-email-hannes@cmpxchg.org>
 <20130803170831.GB23319@cmpxchg.org>
 <20130830215852.3E5D3D66@pobox.sk>
 <20130902123802.5B8E8CB1@pobox.sk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130902123802.5B8E8CB1@pobox.sk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: azurIt <azurit@pobox.sk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

Hello azur,

On Mon, Sep 02, 2013 at 12:38:02PM +0200, azurIt wrote:
> >>Hi azur,
> >>
> >>here is the x86-only rollup of the series for 3.2.
> >>
> >>Thanks!
> >>Johannes
> >>---
> >
> >
> >Johannes,
> >
> >unfortunately, one problem arises: I have (again) cgroup which cannot be deleted :( it's a user who had very high memory usage and was reaching his limit very often. Do you need any info which i can gather now?

Did the OOM killer go off in this group?

Was there a warning in the syslog ("Fixing unhandled memcg OOM
context")?

If it happens again, could you check if there are tasks left in the
cgroup?  And provide /proc/<pid>/stack of the hung task trying to
delete the cgroup?

> Now i can definitely confirm that problem is NOT fixed :( it happened again but i don't have any data because i already disabled all debug output.

Which debug output?

Do you still have access to the syslog?

It's possible that, as your system does not deadlock on the OOMing
cgroup anymore, you hit a separate bug...

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
