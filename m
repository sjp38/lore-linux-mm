Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 253B36B002C
	for <linux-mm@kvack.org>; Tue, 31 Jan 2012 14:59:42 -0500 (EST)
Received: by qcsd16 with SMTP id d16so291555qcs.14
        for <linux-mm@kvack.org>; Tue, 31 Jan 2012 11:59:41 -0800 (PST)
MIME-Version: 1.0
Date: Tue, 31 Jan 2012 11:59:40 -0800
Message-ID: <CALWz4iypV=k-7gVcFx=OsHJsWcUzQsfEoYbQ4+ySQoTob_PWcQ@mail.gmail.com>
Subject: [LSF/MM TOPIC] [ATTEND] memcg: soft limit reclaim (continue) and others
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org

some topics that I would like to discuss this year:

1) we talked about soft limit redesign during last LSF, and there are
quite a lot of efforts and changes being pushed after that. I would
like to take this time to sync-up our efforts and also discuss some of
the remaining issues.

Discussion from last year :
http://www.spinics.net/lists/linux-mm/msg17102.html and lots of
changes have been made since then.

2) memory.stat, this is the main stat file for all memcg statistics.
are we planning to keep stuff it for something like per-memcg
vmscan_stat, vmstat or not.

3) root cgroup now becomes quite interesting, especially after we
bring back the exclusive lru to root. To be more specific, root cgroup
now is like a sink which contains pages allocated on its own, and also
pages being re-parented. Those pages won't be reclaimed until there is
a global pressure, and we want to see anything we can do better.

--Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
