Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id C2FF2900086
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 06:47:06 -0400 (EDT)
Date: Fri, 15 Apr 2011 11:47:00 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Regression from 2.6.36
Message-ID: <20110415104700.GD22688@suse.de>
References: <1302178426.3357.34.camel@edumazet-laptop>
 <BANLkTikxWy-Pw1PrcAJMHs2R7JKksyQzMQ@mail.gmail.com>
 <1302190586.3357.45.camel@edumazet-laptop>
 <20110412154906.70829d60.akpm@linux-foundation.org>
 <BANLkTincoaxp5Soe6O-eb8LWpgra=k2NsQ@mail.gmail.com>
 <20110412183132.a854bffc.akpm@linux-foundation.org>
 <1302662256.2811.27.camel@edumazet-laptop>
 <20110413141600.28793661.akpm@linux-foundation.org>
 <20110414102501.GE11871@csn.ul.ie>
 <20110415115903.315DEAA1@pobox.sk>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110415115903.315DEAA1@pobox.sk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: azurIt <azurit@pobox.sk>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Eric Dumazet <eric.dumazet@gmail.com>, Changli Gao <xiaosuo@gmail.com>, Am?rico Wang <xiyou.wangcong@gmail.com>, Jiri Slaby <jslaby@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Jiri Slaby <jirislaby@gmail.com>

On Fri, Apr 15, 2011 at 11:59:03AM +0200, azurIt wrote:
> 
> Also this new patch is working fine and fixing the problem.
> 
> Mel, I cannot run your script:
> # perl watch-highorder-latency.pl
> Failed to open /sys/kernel/debug/tracing/set_ftrace_filter for writing at watch-highorder-latency.pl line 17.
> 
> # ls -ld /sys/kernel/debug/
> ls: cannot access /sys/kernel/debug/: No such file or directory
> 

mount -t debugfs none /sys/kernel/debug

If it still doesn't work, sysfs or the necessary FTRACE options are
not enabled on your .config. I'll give you a list if that is the case.

Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
