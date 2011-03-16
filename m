Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5A9018D0039
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 15:26:41 -0400 (EDT)
Received: by bwz17 with SMTP id 17so2519910bwz.14
        for <linux-mm@kvack.org>; Wed, 16 Mar 2011 12:26:38 -0700 (PDT)
Subject: Re: [PATCH 1/8] drivers/random: Cache align ip_random better
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <1300299787.3128.495.camel@calx>
References: <20110316022804.27679.qmail@science.horizon.com>
	 <alpine.LSU.2.00.1103161011370.13407@sister.anvils>
	 <1300299787.3128.495.camel@calx>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 16 Mar 2011 20:26:33 +0100
Message-ID: <1300303593.3202.30.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: Hugh Dickins <hughd@google.com>, George Spelvin <linux@horizon.com>, penberg@cs.helsinki.fi, herbert@gondor.hengli.com.au, linux-mm@kvack.org, linux-kernel@vger.kernel.org


> I think this alignment exists to minimize the number of cacheline
> bounces on SMP as this can be a pretty hot structure in the network
> stack. It could probably benefit from a per-cpu treatment.
> 

Well, this is a mostly read area of memory, dirtied every 5 minutes.

Compare this to 'jiffies' for example ;)

What could be done is to embed 'ip_cnt' inside ip_keydata[0] for
example, to avoid wasting a cache line for one bit ;)


c1606c40 b ip_cnt
<hole>
c1606c80 b ip_keydata


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
