Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id AF8A86B007E
	for <linux-mm@kvack.org>; Sun, 17 Jul 2011 04:52:22 -0400 (EDT)
Message-ID: <4E22A2BC.2080900@gmx.de>
Date: Sun, 17 Jul 2011 10:52:12 +0200
From: Thomas Sattler <tsattler@gmx.de>
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] Fix compaction stalls due to accounting errors in
 isolated page accounting
References: <1307459225-4481-1-git-send-email-mgorman@suse.de>
In-Reply-To: <1307459225-4481-1-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Ury Stankevich <urykhy@gmail.com>, Andi Kleen <andi@firstfloor.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

Hi there ...

> Re-verification from testers that these patches really do fix their
> problems would be appreciated. Even if hangs disappear, please confirm
> that the values for nr_isolated_anon and nr_isolated_file in *both*
> /proc/zoneinfo and /proc/vmstat are sensible (i.e. usually zero).

I applied these patches to 2.6.38.8 and it run for nearly a month
without any problems. Even Though I did not check nr_isolated_*.
As (at least) patch3 made it into 2.6.39.3 I did not apply the
others any more. And it occurred again this morning:


  sysload at 2, iowait at 80% on an idle (single core) system


$ grep nr_isolated /proc/zoneinfo /proc/vmstat
/proc/zoneinfo:    nr_isolated_anon 0
/proc/zoneinfo:    nr_isolated_file 1
/proc/zoneinfo:    nr_isolated_anon 0
/proc/zoneinfo:    nr_isolated_file 4294967295
/proc/zoneinfo:    nr_isolated_anon 0
/proc/zoneinfo:    nr_isolated_file 0
/proc/vmstat:nr_isolated_anon 0
/proc/vmstat:nr_isolated_file 0

I captured several SysRq-* logs, in case they're of interest.

Thomas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
