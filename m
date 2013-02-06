Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id C653E6B0005
	for <linux-mm@kvack.org>; Wed,  6 Feb 2013 11:23:08 -0500 (EST)
Received: by mail-ie0-f180.google.com with SMTP id bn7so2108990ieb.39
        for <linux-mm@kvack.org>; Wed, 06 Feb 2013 08:23:07 -0800 (PST)
MIME-Version: 1.0
Date: Wed, 6 Feb 2013 10:23:06 -0600
Message-ID: <CAG-w=x7NnBGn_W8HAjL+Qz0SnP2T_tzxfHjvRiddxVZ_CFT9DA@mail.gmail.com>
Subject: [ATTEND][LSF/MM TOPIC] Compressed Swap Caching
From: Seth Jennings <spartacus06@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, Bryan Jacobson <bjacobson@us.ibm.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Seth Jennings <sjenning@linux.vnet.ibm.com>

(Sorry if this is a dup.  Last attempt to send this got hung up in the
mail relay and it's fate is unknown.  Sending from my personal gmail now.)

It's great to see all the work being done to improve swap performance.
I'd like to contribute to this discussion by focusing a topic
specifically at the value of having a compressed swap cache in the
kernel.  I am currently working on the zswap code [1] to do just this.
Compressed swap cache can mitigate the latency and nondeterminism
associated with swapping by drastically reducing I/O to the swap device.
The I/O reduction with zswap is very impressive [2].  I think a
compressed swap cache would be a very attractive mm feature for the kernel.

Zswap contains solutions for avoiding inverse LRU and writeback for
pages contained in the compressed pool.

I would like to talk about the approach zswap uses and also discuss the
policies involved like the sizing of the compressed pool and writeback
policy.

[1] https://lkml.org/lkml/2013/1/29/543
[2] http://ibm.co/VCgHvN

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
