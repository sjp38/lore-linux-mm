Date: Tue, 18 Nov 2003 12:22:15 -0500 (EST)
From: Zwane Mwaikambo <zwane@arm.linux.org.uk>
Subject: Re: [PATCH][2.6-mm] Fix 4G/4G X11/vm86 oops
In-Reply-To: <149480000.1069177112@flay>
Message-ID: <Pine.LNX.4.53.0311181219490.11537@montezuma.fsmlabs.com>
References: <Pine.LNX.4.44.0311180830050.18739-100000@home.osdl.org>
 <Pine.LNX.4.53.0311181149310.11537@montezuma.fsmlabs.com> <149480000.1069177112@flay>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Linus Torvalds <torvalds@osdl.org>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@osdl.org>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Tue, 18 Nov 2003, Martin J. Bligh wrote:

> The other thing I've found printks to hide before is timing bugs / races.
> Unfortunately I can't see one here, but maybe someone else can ;-)
> Maybe inserting a 1ms delay or something in place of the printk would
> have the same effect?

I've tried a number of timing related workarounds, namely;
schedule_timeout(2*HZ) and some long spinning loops. I've also thrown a 
schedule() in there at some point.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
