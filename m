Date: Tue, 18 Nov 2003 09:38:32 -0800
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: [PATCH][2.6-mm] Fix 4G/4G X11/vm86 oops
Message-ID: <149480000.1069177112@flay>
In-Reply-To: <Pine.LNX.4.53.0311181149310.11537@montezuma.fsmlabs.com>
References: <Pine.LNX.4.44.0311180830050.18739-100000@home.osdl.org> <Pine.LNX.4.53.0311181149310.11537@montezuma.fsmlabs.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Zwane Mwaikambo <zwane@arm.linux.org.uk>, Linus Torvalds <torvalds@osdl.org>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@osdl.org>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

>> Btw, you seem to compile with debugging, which makes the assembly 
>> language pretty much unreadable and accounts for most of the 
>> differences: the line numbers change. If you compile a kernel where the 
>> line numbers don't change (by commenting _out_ the printk rather than 
>> removing the whole line), your diff would be more readable.
> 
> Aha! Thanks for mentioning that, noted.
> 
>> Anyway, there are _zero_ differences.
>> 
>> Just for fun, try this: move the "printk()" to _below_ the "asm"  
>> statement. It will never actually get executed, but if it's an issue of
>> some subtle code or data placement things (cache lines etc), maybe that
>> also hides the oops, since all the same code and data will be generated, 
>> just not run...
> 
> Ok i just tried that and it still fails. Matt Mackall suggested i also try 
> writing a minimal printk which has the same effect.

The other thing I've found printks to hide before is timing bugs / races.
Unfortunately I can't see one here, but maybe someone else can ;-)
Maybe inserting a 1ms delay or something in place of the printk would
have the same effect?

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
