Date: Wed, 29 Jan 2003 01:51:34 -0800 (PST)
Message-Id: <20030129.015134.19663914.davem@redhat.com>
Subject: Re: Linus rollup
From: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030129095949.A24161@flint.arm.linux.org.uk>
References: <20030128220729.1f61edfe.akpm@digeo.com>
	<20030129095949.A24161@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: rmk@arm.linux.org.uk
Cc: akpm@digeo.com, ak@muc.de, davidm@napali.hpl.hp.com, anton@samba.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

   
   	/* This function must be called with interrupts disabled
   
   which hasn't been true for some time, and is even less true now that
   local IRQs don't get disabled.  Does this matter... for UP?

I disable local IRQs during gettimeofday() on sparc.

These locks definitely need to be taken with IRQs disabled.
Why isn't x86 doing that?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
