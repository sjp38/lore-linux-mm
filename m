From: David Mosberger <davidm@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <15928.2469.865487.687367@napali.hpl.hp.com>
Date: Wed, 29 Jan 2003 09:04:37 -0800
Subject: Re: Linus rollup
In-Reply-To: <20030129095949.A24161@flint.arm.linux.org.uk>
References: <20030128220729.1f61edfe.akpm@digeo.com>
	<20030129095949.A24161@flint.arm.linux.org.uk>
Reply-To: davidm@hpl.hp.com
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Russell King <rmk@arm.linux.org.uk>
Cc: Andrew Morton <akpm@digeo.com>, Andi Kleen <ak@muc.de>, "David S. Miller" <davem@redhat.com>, David Mosberger <davidm@napali.hpl.hp.com>, Anton Blanchard <anton@samba.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> On Wed, 29 Jan 2003 09:59:49 +0000, Russell King <rmk@arm.linux.org.uk> said:

  Russell> On Tue, Jan 28, 2003 at 10:07:29PM -0800, Andrew Morton
  Russell> wrote:

  >> The frlock code is showing nice speedups, but I think the main
  >> reason we want this is to fix the problem wherein an application
  >> spinning on gettimeofday() can make time stop.

  Russell> I'm slightly concerned about this.  With this patch, we
  Russell> generally seem to do:

  Russell> [snip...]

  Russell> The same is true for other architectures; their
  Russell> gettimeoffset implementations need to be audited by the
  Russell> architecture maintainers to ensure that they are safe to
  Russell> run with (local) interrupts enabled.

Should be fine as far as ia64 is concerned, since gettimeoffset()
currently simply reads the cycle-counter (and I think even HPET-based
interpolation would be lock-free).

	--david
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
