Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 5B3958D0039
	for <linux-mm@kvack.org>; Sat, 19 Feb 2011 21:59:12 -0500 (EST)
Date: Sat, 19 Feb 2011 18:59:46 -0800 (PST)
Message-Id: <20110219.185946.193690650.davem@davemloft.net>
Subject: Re: [PATCH] tcp: fix inet_twsk_deschedule()
From: David Miller <davem@davemloft.net>
In-Reply-To: <1298104556.8559.21.camel@edumazet-laptop>
References: <20110218191146.GG13211@ghostprotocols.net>
	<m1sjvl2i3q.fsf@fess.ebiederm.org>
	<1298104556.8559.21.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: eric.dumazet@gmail.com
Cc: ebiederm@xmission.com, acme@redhat.com, torvalds@linux-foundation.org, mhocko@suse.cz, mingo@elte.hu, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, xemul@openvz.org, daniel.lezcano@free.fr

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 19 Feb 2011 09:35:56 +0100

> [PATCH] tcp: fix inet_twsk_deschedule()
> 
> Eric W. Biederman reported a lockdep splat in inet_twsk_deschedule()
> 
> This is caused by inet_twsk_purge(), run from process context,
> and commit 575f4cd5a5b6394577 (net: Use rcu lookups in inet_twsk_purge.)
> removed the BH disabling that was necessary.
> 
> Add the BH disabling but fine grained, right before calling
> inet_twsk_deschedule(), instead of whole function.
> 
> With help from Linus Torvalds and Eric W. Biederman
> 
> Reported-by: Eric W. Biederman <ebiederm@xmission.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Daniel Lezcano <daniel.lezcano@free.fr>
> CC: Pavel Emelyanov <xemul@openvz.org>
> CC: Arnaldo Carvalho de Melo <acme@redhat.com>
> CC: stable <stable@kernel.org> (# 2.6.33+)

Applied, thanks Eric.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
