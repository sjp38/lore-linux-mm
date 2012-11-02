Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 7D28B6B0044
	for <linux-mm@kvack.org>; Fri,  2 Nov 2012 19:31:16 -0400 (EDT)
Received: by mail-ia0-f169.google.com with SMTP id h37so3769621iak.14
        for <linux-mm@kvack.org>; Fri, 02 Nov 2012 16:31:15 -0700 (PDT)
Date: Fri, 2 Nov 2012 16:31:18 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] memcg: fix hotplugged memory zone oops
In-Reply-To: <20121102102159.GA24073@dhcp22.suse.cz>
Message-ID: <alpine.LNX.2.00.1211021626150.11106@eggly.anvils>
References: <505187D4.7070404@cn.fujitsu.com> <20120913205935.GK1560@cmpxchg.org> <alpine.LSU.2.00.1209131816070.1908@eggly.anvils> <507CF789.6050307@cn.fujitsu.com> <alpine.LSU.2.00.1210181129180.2137@eggly.anvils> <20121018220306.GA1739@cmpxchg.org>
 <alpine.LNX.2.00.1211011822190.20048@eggly.anvils> <20121102102159.GA24073@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Wen Congyang <wency@cn.fujitsu.com>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, Jiang Liu <liuj97@gmail.com>, bsingharora@gmail.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, paul.gortmaker@windriver.com, Tang Chen <tangchen@cn.fujitsu.com>

On Fri, 2 Nov 2012, Michal Hocko wrote:
> 
> OK, it adds "an overhead" also when there is no hotadd going on but this
> is just one additional mem access&cmp&je so it shouldn't be noticable
> (lruvec->zone is used most of the time later so it not a pointless
> load).

I think so too.

> It is also easier to backport for stable.

Yes.

> But is there any reason to fix it later properly in the hotadd hook?

I don't know.  Not everybody liked it fixed this way: it's not
unreasonable to see this as a quick hack rather than the right fix.

I was expecting objectors to post alternative hotadd hook patches,
then we could compare and decide.  That didn't happen; but we can
certainly look to taking out these lines later if something we
agree is better comes along.  Not high on anyone's agenda, I think.

> 
> Anyway
> Acked-by: Michal Hocko <mhocko@suse.cz>

Thanks,
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
