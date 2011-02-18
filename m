Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id BEA968D0039
	for <linux-mm@kvack.org>; Fri, 18 Feb 2011 15:13:56 -0500 (EST)
Date: Fri, 18 Feb 2011 12:14:31 -0800 (PST)
Message-Id: <20110218.121431.183035903.davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: deinit automatic LIST_HEAD
From: David Miller <davem@davemloft.net>
In-Reply-To: <1298019559.2595.92.camel@edumazet-laptop>
References: <AANLkTimzP0UNRXutkt1zJ+OGhmeg6ga87HFyMuZQmpMj@mail.gmail.com>
	<m17hcx7wca.fsf@fess.ebiederm.org>
	<1298019559.2595.92.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: eric.dumazet@gmail.com
Cc: torvalds@linux-foundation.org, ebiederm@xmission.com, mingo@elte.hu, opurdila@ixiacom.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, netdev@vger.kernel.org, stable@kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 18 Feb 2011 09:59:19 +0100

> commit 9b5e383c11b08784 (net: Introduce
> unregister_netdevice_many()) left an active LIST_HEAD() in
> rollback_registered(), with possible memory corruption.
> 
> Even if device is freed without touching its unreg_list (and therefore
> touching the previous memory location holding LISTE_HEAD(single), better
> close the bug for good, since its really subtle.
> 
> (Same fix for default_device_exit_batch() for completeness)
> 
> Reported-by: Michal Hocko <mhocko@suse.cz>
> Reported-by: Eric W. Biderman <ebiderman@xmission.com>
> Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
