Subject: Re: [patch] Converting writeback linked lists to a tree based data structure
From: Andi Kleen <andi@firstfloor.org>
References: <20080115080921.70E3810653@localhost>
	<400562938.07583@ustc.edu.cn>
	<532480950801171307q4b540ewa3acb6bfbea5dbc8@mail.gmail.com>
	<400632190.14601@ustc.edu.cn>
Date: Fri, 18 Jan 2008 06:41:09 +0100
In-Reply-To: <400632190.14601@ustc.edu.cn> (Fengguang Wu's message of "Fri\, 18 Jan 2008 12\:56\:09 +0800")
Message-ID: <p738x2nbsi2.fsf@bingen.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Fengguang Wu <wfg@mail.ustc.edu.cn>
Cc: Michael Rubin <mrubin@google.com>, a.p.zijlstra@chello.nl, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Fengguang Wu <wfg@mail.ustc.edu.cn> writes:
>
> Suppose we want to grant longer expiration window for temp files,
> adding a new list named s_dirty_tmpfile would be a handy solution.

How would the kernel know that a file is a tmp file?

> So the question is: should we need more than 3 QoS classes?

[just a random idea; i have not worked out all the implications]

Would it be possible to derive a writeback apriority from the ionice
level of the process originating the IO? e.g. we have long standing
problems that background jobs even when niced and can cause
significant slow downs to foreground processes by starving IO 
and pushing out pages. ionice was supposed to help with that
but in practice it does not seem to have helped too much and I suspect
it needs more prioritization higher up the VM food chain. Adding
such priorities to writeback would seem like a step in the right
direction, although it would of course not solve the problem
completely.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
