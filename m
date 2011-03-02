Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id E3B3D8D0039
	for <linux-mm@kvack.org>; Wed,  2 Mar 2011 14:53:35 -0500 (EST)
Date: Wed, 02 Mar 2011 11:54:11 -0800 (PST)
Message-Id: <20110302.115411.183067873.davem@davemloft.net>
Subject: Re: [PATCH v3 0/4] exec: unify native/compat code
From: David Miller <davem@davemloft.net>
In-Reply-To: <AANLkTi=e7n63cCTUe1T+C0d6Ni1VVBFZZ6y_rj-2RQwu@mail.gmail.com>
References: <AANLkTinzQmprg+XHKjTj7bA+jFf_N4hta3_09M+SEfRt@mail.gmail.com>
	<20110302.114018.104077586.davem@davemloft.net>
	<AANLkTi=e7n63cCTUe1T+C0d6Ni1VVBFZZ6y_rj-2RQwu@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org
Cc: oleg@redhat.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, pageexec@freemail.hu, solar@openwall.com, eteo@redhat.com, spender@grsecurity.net, roland@redhat.com, miltonm@bga.com

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 2 Mar 2011 11:48:03 -0800

> Well, the thing is, on architectures that _can_ pass by value, it
> avoids one indirection.
> 
> And if you do pass it on stack, then the code generated will be the
> same as if we passed a pointer. So sparc may not be able to take
> advantage of the optimization, but I don't think the code generation
> would be worse.

That's a good point, the situation here is different than the page table
one.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
