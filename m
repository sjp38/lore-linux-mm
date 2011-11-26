Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id E01C56B0093
	for <linux-mm@kvack.org>; Sat, 26 Nov 2011 15:49:46 -0500 (EST)
Date: Sat, 26 Nov 2011 15:49:39 -0500 (EST)
Message-Id: <20111126.154939.980893642757282901.davem@davemloft.net>
Subject: Re: [BUG] 3.2-rc2: BUG kmalloc-8: Redzone overwritten
From: David Miller <davem@davemloft.net>
In-Reply-To: <1322305162.10212.8.camel@edumazet-laptop>
References: <1321870967.8173.1.camel@lappy>
	<1322304878.28191.1.camel@sasha>
	<1322305162.10212.8.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: eric.dumazet@gmail.com
Cc: levinsasha928@gmail.com, mpm@selenic.com, cl@linux-foundation.org, penberg@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 26 Nov 2011 11:59:22 +0100

> Le samedi 26 novembre 2011 =E0 12:54 +0200, Sasha Levin a =E9crit :
>> > On Mon, 2011-11-21 at 11:21 +0100, Eric Dumazet wrote:
>> > > =

>> > > Hmm, I forgot to remove the sock_hold(sk) call from dn_slow_time=
r(),
>> > > here is V2 :
>> > > =

>> > > [PATCH] decnet: proper socket refcounting
>> > > =

>> > > Better use sk_reset_timer() / sk_stop_timer() helpers to make su=
re we
>> > > dont access already freed/reused memory later.
>> > > =

>> > > Reported-by: Sasha Levin <levinsasha928@gmail.com>
>> > > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>> > > ---
>> > =

>> > =

>> > Applied locally and running same tests as before, will update with=

>> > results.
>> > =

>> =

>> Looks ok after a couple days of testing.
>> =

>> 	Tested-by: Sasha Levin <levinsasha928@gmail.com>
>> =

> =

> Thanks Sasha !

Applied and queued up for -stable, thanks everyone.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
