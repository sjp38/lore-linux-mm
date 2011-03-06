Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 779AF8D0039
	for <linux-mm@kvack.org>; Sun,  6 Mar 2011 12:10:41 -0500 (EST)
Date: Sun, 6 Mar 2011 18:01:56 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH v5 0/4] exec: unify native/compat code
Message-ID: <20110306170156.GA24175@redhat.com>
References: <AANLkTimp=mhedXLdrZFqK2QWYvg7MdmUPj3-Q9m2vtTx@mail.gmail.com> <20110305203040.GA7546@redhat.com> <20110306210334.6CD5.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110306210334.6CD5.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, pageexec@freemail.hu, Solar Designer <solar@openwall.com>, Eugene Teo <eteo@redhat.com>, Brad Spengler <spender@grsecurity.net>, Roland McGrath <roland@redhat.com>, Milton Miller <miltonm@bga.com>, Linus Torvalds <torvalds@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On 03/06, KOSAKI Motohiro wrote:
>
> And, I happily reported this series run successfully my testsuite.
> Could you please add my tested-by tag?

Sure, thanks a lot Kosaki.

I hope this is the last version. Changes:

	- as Linus pointed out, we do not have compat_uptr_t without
	  CONFIG_COMPAT. Add another ifdef into struct user_arg_ptr.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
