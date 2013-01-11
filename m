Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id C58606B005D
	for <linux-mm@kvack.org>; Thu, 10 Jan 2013 21:40:03 -0500 (EST)
Received: by mail-ee0-f42.google.com with SMTP id b47so238934eek.29
        for <linux-mm@kvack.org>; Thu, 10 Jan 2013 18:40:02 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1357870727.27446.2988.camel@edumazet-glaptop>
References: <20130111004915.GA15415@dcvr.yhbt.net>
	<1357869675.27446.2962.camel@edumazet-glaptop>
	<1357870727.27446.2988.camel@edumazet-glaptop>
Date: Thu, 10 Jan 2013 21:40:01 -0500
Message-ID: <CADVnQy==hkO5jFH9ah3U-1Joy2D-wkRq80n0dHf6HxfRLS9Hjg@mail.gmail.com>
Subject: Re: 3.8-rc2/rc3 write() blocked on CLOSE_WAIT TCP socket
From: Neal Cardwell <ncardwell@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Eric Wong <normalperson@yhbt.net>, David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Thu, Jan 10, 2013 at 9:18 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> On Thu, 2013-01-10 at 18:01 -0800, Eric Dumazet wrote:
>
>> Hmm, it might be commit c3ae62af8e755ea68380fb5ce682e60079a4c388
>> tcp: should drop incoming frames without ACK flag set
>>
>> It seems RST should be allowed to not have ACK set.
>>
>> I'll send a fix, thanks !
>
> Yes, thats definitely the problem, sorry for that.
>
>
> [PATCH] tcp: accept RST without ACK flag
>
> commit c3ae62af8e755 (tcp: should drop incoming frames without ACK flag
> set) added a regression on the handling of RST messages.
>
> RST should be allowed to come even without ACK bit set. We validate
> the RST by checking the exact sequence, as requested by RFC 793 and
> 5961 3.2, in tcp_validate_incoming()
>
> Reported-by: Eric Wong <normalperson@yhbt.net>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Acked-by: Neal Cardwell <ncardwell@google.com>

neal

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
