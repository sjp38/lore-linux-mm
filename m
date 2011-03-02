Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 737A28D0039
	for <linux-mm@kvack.org>; Wed,  2 Mar 2011 14:39:42 -0500 (EST)
Date: Wed, 02 Mar 2011 11:40:18 -0800 (PST)
Message-Id: <20110302.114018.104077586.davem@davemloft.net>
Subject: Re: [PATCH v3 0/4] exec: unify native/compat code
From: David Miller <davem@davemloft.net>
In-Reply-To: <AANLkTinzQmprg+XHKjTj7bA+jFf_N4hta3_09M+SEfRt@mail.gmail.com>
References: <20110302162650.GA26810@redhat.com>
	<20110302164428.GF26810@redhat.com>
	<AANLkTinzQmprg+XHKjTj7bA+jFf_N4hta3_09M+SEfRt@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org
Cc: oleg@redhat.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, pageexec@freemail.hu, solar@openwall.com, eteo@redhat.com, spender@grsecurity.net, roland@redhat.com, miltonm@bga.com

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 2 Mar 2011 10:00:23 -0800

> No, I think we're ok with passing the structure by value - it's a
> small structure that would generally be passed in registers (at least
> on some architectures, I guess it will depend on the ABI), and we do
> the "struct-by-value" thing for other things too (notably the page
> table entries), so it's not a new thing in the kernel.

We purposely don't do that "page table entry typedef'd to aggregate" stuff
on sparc32 because otherwise such values get passed on the stack.

Architectures can currently avoid this bad code generation for the
page table case, but with this new code they won't be able to avoid
pass-by-value.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
