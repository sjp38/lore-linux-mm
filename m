Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 485FE6B0031
	for <linux-mm@kvack.org>; Thu,  5 Sep 2013 08:45:25 -0400 (EDT)
Date: Thu, 5 Sep 2013 14:45:23 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 0/7] improve memcg oom killer robustness v2
Message-ID: <20130905124523.GC13666@dhcp22.suse.cz>
References: <20130904115741.GA28285@dhcp22.suse.cz>
 <20130904141000.0F910EFA@pobox.sk>
 <20130904122632.GB28285@dhcp22.suse.cz>
 <20130905111430.CB1392B4@pobox.sk>
 <20130905095331.GA9702@dhcp22.suse.cz>
 <20130905121700.546B5881@pobox.sk>
 <20130905111742.GC9702@dhcp22.suse.cz>
 <20130905134702.C703F65B@pobox.sk>
 <20130905120347.GA13666@dhcp22.suse.cz>
 <20130905143343.AF56A889@pobox.sk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130905143343.AF56A889@pobox.sk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: azurIt <azurit@pobox.sk>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu 05-09-13 14:33:43, azurIt wrote:
[...]
> >Just to be sure I got you right. You have killed all the processes from
> >the group you have sent stacks for, right? If that is the case I am
> >really curious about processes sitting in sleep_on_page_killable because
> >those are killable by definition.
> 
> Yes, my script killed all of that processes right after taking
> stack.

OK, _after_ part is important. Has the group gone away after then?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
