Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 4C5176B003D
	for <linux-mm@kvack.org>; Thu, 19 Feb 2009 14:00:11 -0500 (EST)
Received: by fg-out-1718.google.com with SMTP id 19so1154985fgg.4
        for <linux-mm@kvack.org>; Thu, 19 Feb 2009 11:00:08 -0800 (PST)
Date: Thu, 19 Feb 2009 22:06:37 +0300
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Banning checkpoint (was: Re: What can OpenVZ do?)
Message-ID: <20090219190637.GA4846@x200.localdomain>
References: <20090213105302.GC4608@elte.hu> <1234817490.30155.287.camel@nimitz> <20090217222319.GA10546@elte.hu> <1234909849.4816.9.camel@nimitz> <20090218003217.GB25856@elte.hu> <1234917639.4816.12.camel@nimitz> <20090218051123.GA9367@x200.localdomain> <20090218181644.GD19995@elte.hu> <1234992447.26788.12.camel@nimitz> <20090218231545.GA17524@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090218231545.GA17524@elte.hu>
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, Nathan Lynch <nathanl@austin.ibm.com>, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, mpm@selenic.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, viro@zeniv.linux.org.uk, hpa@zytor.com, Andrew Morton <akpm@linux-foundation.org>, torvalds@linux-foundation.org, tglx@linutronix.de, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

I think that all these efforts to abort checkpoint "intelligently" by
banning it early are completely misguided.

"Checkpointable" property isn't one-way ticket like "tainted" flag,
so doing it like tainted var isn't right, atomic or not, SMP-safe or
not.

With filesystems, one has ->f_op field to compare against banned
filesystems, one more flag isn't necessary.

Inotify isn't supported yet? You do

	if (!list_empty(&inode->inotify_watches))
		return -E;

without hooking into inotify syscalls.

ptrace(2) isn't supported -- look at struct task_struct::ptraced and
friends.

And so on.

System call (or whatever) does something with some piece of kernel
internals. We look at this "something" when walking data structures and
abort if it's scary enough.

Please, show at least one counter-example.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
