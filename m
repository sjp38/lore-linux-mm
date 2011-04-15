Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 7E4A7900086
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 06:56:53 -0400 (EDT)
Subject: Re: Regression from 2.6.36
Date: Fri, 15 Apr 2011 12:56:51 +0200
From: "azurIt" <azurit@pobox.sk>
References: <1302178426.3357.34.camel@edumazet-laptop> <BANLkTikxWy-Pw1PrcAJMHs2R7JKksyQzMQ@mail.gmail.com> <1302190586.3357.45.camel@edumazet-laptop> <20110412154906.70829d60.akpm@linux-foundation.org> <BANLkTincoaxp5Soe6O-eb8LWpgra=k2NsQ@mail.gmail.com> <20110412183132.a854bffc.akpm@linux-foundation.org> <1302662256.2811.27.camel@edumazet-laptop> <20110413141600.28793661.akpm@linux-foundation.org> <20110414102501.GE11871@csn.ul.ie> <20110415115903.315DEAA1@pobox.sk> <20110415104700.GD22688@suse.de>
In-Reply-To: <20110415104700.GD22688@suse.de>
MIME-Version: 1.0
Message-Id: <20110415125651.68156745@pobox.sk>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Eric Dumazet <eric.dumazet@gmail.com>, Changli Gao <xiaosuo@gmail.com>, Am?rico Wang <xiyou.wangcong@gmail.com>, Jiri Slaby <jslaby@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Jiri Slaby <jirislaby@gmail.com>


# mount -t debugfs none /sys/kernel/debug
mount: mount point /sys/kernel/debug does not exist

# mkdir /sys/kernel/debug
mkdir: cannot create directory `/sys/kernel/debug': No such file or directory


config file used for testing is here:
http://watchdog.sk/lkml/config


azur


______________________________________________________________
> Od: "Mel Gorman" <mgorman@suse.de>
> Komu: azurIt <azurit@pobox.sk>
> DA!tum: 15.04.2011 12:47
> Predmet: Re: Regression from 2.6.36
>
> CC: "Mel Gorman" <mel@csn.ul.ie>, "Andrew Morton" <akpm@linux-foundation.org>, "Eric Dumazet" <eric.dumazet@gmail.com>, "Changli Gao" <xiaosuo@gmail.com>, "Am?rico Wang" <xiyou.wangcong@gmail.com>, "Jiri Slaby" <jslaby@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Jiri Slaby" <jirislaby@gmail.com>
>On Fri, Apr 15, 2011 at 11:59:03AM +0200, azurIt wrote:
>> 
>> Also this new patch is working fine and fixing the problem.
>> 
>> Mel, I cannot run your script:
>> # perl watch-highorder-latency.pl
>> Failed to open /sys/kernel/debug/tracing/set_ftrace_filter for writing at watch-highorder-latency.pl line 17.
>> 
>> # ls -ld /sys/kernel/debug/
>> ls: cannot access /sys/kernel/debug/: No such file or directory
>> 
>
>mount -t debugfs none /sys/kernel/debug
>
>If it still doesn't work, sysfs or the necessary FTRACE options are
>not enabled on your .config. I'll give you a list if that is the case.
>
>Thanks.
>
>-- 
>Mel Gorman
>SUSE Labs
>--
>To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>Please read the FAQ at  http://www.tux.org/lkml/
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
