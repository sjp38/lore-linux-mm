Date: Wed, 29 Jan 2003 17:25:19 +0000
From: Russell King <rmk@arm.linux.org.uk>
Subject: Re: Linus rollup
Message-ID: <20030129172519.C6261@flint.arm.linux.org.uk>
References: <20030128220729.1f61edfe.akpm@digeo.com> <20030129095949.A24161@flint.arm.linux.org.uk> <15928.2469.865487.687367@napali.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <15928.2469.865487.687367@napali.hpl.hp.com>; from davidm@napali.hpl.hp.com on Wed, Jan 29, 2003 at 09:04:37AM -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: davidm@hpl.hp.com
Cc: Andrew Morton <akpm@digeo.com>, Andi Kleen <ak@muc.de>, "David S. Miller" <davem@redhat.com>, David Mosberger <davidm@napali.hpl.hp.com>, Anton Blanchard <anton@samba.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 29, 2003 at 09:04:37AM -0800, David Mosberger wrote:
> Should be fine as far as ia64 is concerned, since gettimeoffset()
> currently simply reads the cycle-counter (and I think even HPET-based
> interpolation would be lock-free).

If you're happy, then I'm happy.

I was only concerned because it looks like it might be a problem on
some implementations, and I was wondering what would happen on ia64
if a timer interrupt occurs between reading jiffies and itm_next in
gettimeoffset.

-- 
Russell King (rmk@arm.linux.org.uk)                The developer of ARM Linux
             http://www.arm.linux.org.uk/personal/aboutme.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
