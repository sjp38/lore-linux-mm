From: David Mosberger <davidm@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <15928.9700.535616.890815@napali.hpl.hp.com>
Date: Wed, 29 Jan 2003 11:05:08 -0800
Subject: Re: Linus rollup
In-Reply-To: <20030129172519.C6261@flint.arm.linux.org.uk>
References: <20030128220729.1f61edfe.akpm@digeo.com>
	<20030129095949.A24161@flint.arm.linux.org.uk>
	<15928.2469.865487.687367@napali.hpl.hp.com>
	<20030129172519.C6261@flint.arm.linux.org.uk>
Reply-To: davidm@hpl.hp.com
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Russell King <rmk@arm.linux.org.uk>
Cc: davidm@hpl.hp.com, Andrew Morton <akpm@digeo.com>, Andi Kleen <ak@muc.de>, "David S. Miller" <davem@redhat.com>, David Mosberger <davidm@napali.hpl.hp.com>, Anton Blanchard <anton@samba.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> On Wed, 29 Jan 2003 17:25:19 +0000, Russell King <rmk@arm.linux.org.uk> said:

  Russell> I was only concerned because it looks like it might be a
  Russell> problem on some implementations, and I was wondering what
  Russell> would happen on ia64 if a timer interrupt occurs between
  Russell> reading jiffies and itm_next in gettimeoffset.

Perhaps I'm missing something, but I thought that in this case,
fr_write_unlock() would increment the counter and cause the reader(s)
to restart the reading of the time-related variables.

I do agree that, in general, there is a potential deadlock if
gettimeoffset() is not lock-free.

	--david
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
