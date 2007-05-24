Subject: Re: [patch 3/8] mm: merge nopfn into fault
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <alpine.LFD.0.98.0705232028510.3890@woody.linux-foundation.org>
References: <200705180737.l4I7b6cg010758@shell0.pdx.osdl.net>
	 <alpine.LFD.0.98.0705180817550.3890@woody.linux-foundation.org>
	 <1179963619.32247.991.camel@localhost.localdomain>
	 <20070524014223.GA22998@wotan.suse.de>
	 <alpine.LFD.0.98.0705231857090.3890@woody.linux-foundation.org>
	 <1179976659.32247.1026.camel@localhost.localdomain>
	 <1179977184.32247.1032.camel@localhost.localdomain>
	 <alpine.LFD.0.98.0705232028510.3890@woody.linux-foundation.org>
Content-Type: text/plain
Date: Thu, 24 May 2007 13:48:18 +1000
Message-Id: <1179978498.32247.1038.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2007-05-23 at 20:37 -0700, Linus Torvalds wrote:
> 
> So just about any "hiding" would do it as far as I'm concerned. Ranging 
> from the odd (making it a "virtual page number") to just using an 
> inconvenient name that just makes it obvious that it shouldn't be used 
> lightly ("virtual_page_fault_address"), to making it a type that cannot 
> easily be used for that kind of arithmetic ("void __user *" would make 
> sense, no?).

Yes, I like void __user *. I don't like long names because they make the
struct definition ugly though. What about

	void __user	*_fault_target; /* for internal use only */

Is that scary enough ? :-)

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
