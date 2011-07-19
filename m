Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id C3B656B007E
	for <linux-mm@kvack.org>; Tue, 19 Jul 2011 07:24:39 -0400 (EDT)
Message-ID: <4E25696E.1060106@gmx.de>
Date: Tue, 19 Jul 2011 13:24:30 +0200
From: Thomas Sattler <tsattler@gmx.de>
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] Fix compaction stalls due to accounting errors in
 isolated page accounting
References: <1307459225-4481-1-git-send-email-mgorman@suse.de> <4E22A2BC.2080900@gmx.de> <20110719091647.GE5349@suse.de>
In-Reply-To: <20110719091647.GE5349@suse.de>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Ury Stankevich <urykhy@gmail.com>, Andi Kleen <andi@firstfloor.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

> I assume you mean it occured again on 2.6.39.3 and so have submitted
> them to -stable for 2.6.39.x. You're cc'd so you should hear when or if
> they get picked up.

Yes, that's, what I meant:

$ uname -a
Linux pearl 2.6.39.3 #14 PREEMPT Thu Jul 14 17:41:20 CEST 2011 i686
Intel(R) Pentium(R) M processor 1700MHz GenuineIntel GNU/Linux

$ grep nr_isolated /proc/zoneinfo /proc/vmstat
/proc/zoneinfo:    nr_isolated_anon 25
/proc/zoneinfo:    nr_isolated_file 7
/proc/zoneinfo:    nr_isolated_anon 4294967271
/proc/zoneinfo:    nr_isolated_file 4294967289
/proc/zoneinfo:    nr_isolated_anon 0
/proc/zoneinfo:    nr_isolated_file 0
/proc/vmstat:nr_isolated_anon 0
/proc/vmstat:nr_isolated_file 0

$ top  # only headlines
top - 13:23:27 up 2 days,  2:52,  6 users,  load average: 2.30, 2.09, 1.69
Tasks: 132 total,   3 running, 129 sleeping,   0 stopped,   0 zombie
Cpu(s): 16.9%us,  5.6%sy,  0.0%ni,  0.0%id, 77.4%wa,  0.0%hi,  0.0%si,  0.0%st
Mem:   1551416k total,  1449088k used,   102328k free,    80736k buffers
Swap:  4120660k total,    48776k used,  4071884k free,   721312k cached

Thomas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
