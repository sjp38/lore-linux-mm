Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 6C2376B0068
	for <linux-mm@kvack.org>; Fri,  7 Sep 2012 05:48:34 -0400 (EDT)
Message-ID: <5049C221.4030003@parallels.com>
Date: Fri, 7 Sep 2012 13:45:05 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] memcg: first step towards hierarchical controller
References: <20120904143552.GB15683@dhcp22.suse.cz> <50461241.5010300@parallels.com> <20120904145414.GC15683@dhcp22.suse.cz> <50461610.30305@parallels.com> <20120904162501.GE15683@dhcp22.suse.cz> <504709D4.2010800@parallels.com> <20120905144942.GH5388@dhcp22.suse.cz> <20120905201238.GE13737@google.com> <20120906120623.GE22426@dhcp22.suse.cz> <50489270.7060108@parallels.com> <20120906121842.GG22426@dhcp22.suse.cz>
In-Reply-To: <20120906121842.GG22426@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, Dave Jones <davej@redhat.com>, Ben Hutchings <ben@decadent.org.uk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lennart Poettering <lennart@poettering.net>, Kay Sievers <kay.sievers@vrfy.org>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

On 09/06/2012 04:18 PM, Michal Hocko wrote:
>> Just so I understand it:
>> > 
>> > Michal clearly objected before folding his patch with my Kconfig patch.
>> > But is there still opposition to merge both?
> I do not find the config option very much useful but if others feel it
> really is I won't block it.
> 
Tejun, what is your take on this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
