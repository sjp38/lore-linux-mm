Subject: Re: Linus rollup
From: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030130015427.GU1237@dualathlon.random>
References: <20030129022617.62800a6e.akpm@digeo.com>
	 <1043879752.10150.387.camel@dell_ss3.pdx.osdl.net>
	 <20030129151206.269290ff.akpm@digeo.com>
	 <20030129.163034.130834202.davem@redhat.com>
	 <20030129172743.1e11d566.akpm@digeo.com>
	 <20030130013522.GP1237@dualathlon.random>
	 <20030129180054.03ac0d48.akpm@digeo.com>
	 <20030130015427.GU1237@dualathlon.random>
Content-Type: text/plain
Message-Id: <1043948226.10150.587.camel@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Date: 30 Jan 2003 09:37:06 -0800
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Andrew Morton <akpm@digeo.com>, David Miller <davem@redhat.com>, rmk@arm.linux.org.uk, ak@muc.de, davidm@napali.hpl.hp.com, anton@samba.org, linux-mm@kvack.org, rth@twiddle.net
List-ID: <linux-mm.kvack.org>

> you certainly mean wmb() not rmb(), right? If yes, then yes.
> 
> I actually didn't notice the write_begin/end, not sure who could need
> them, I would suggest removing them, rather than to revert the mb()
> there too.

The write_begin/end was suggested by Andrew as a simplification for use
when using this to update values already write-locked by other means.

One possible usage was to fix the race issues with non-atomic update
of 64 bit i_size.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
