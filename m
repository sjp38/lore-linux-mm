Date: Wed, 29 Jan 2003 20:54:17 +1100
From: Anton Blanchard <anton@samba.org>
Subject: Re: Linus rollup
Message-ID: <20030129095417.GB18250@krispykreme>
References: <20030128220729.1f61edfe.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030128220729.1f61edfe.akpm@digeo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Russell King <rmk@arm.linux.org.uk>, Andi Kleen <ak@muc.de>, "David S. Miller" <davem@redhat.com>, David Mosberger <davidm@napali.hpl.hp.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> I've sifted out all the things which I intend to send to the boss soon.  It
> would be good if you could perform some quick non-ia32 testing please.
> 
> Possible breakage would be in the new frlock-for-xtime_lock code and the
> get_order() cleanup.
> 
> The frlock code is showing nice speedups, but I think the main reason we want
> this is to fix the problem wherein an application spinning on gettimeofday()
> can make time stop.

Checks out OK on ppc64 bar some problems with the get_order patch.
(should include linux/bitops.h instead of asm/bitops.h).

It passed some stress tests (sdet, tpc-h)

Anton
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
