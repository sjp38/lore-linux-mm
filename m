Date: Thu, 30 Jan 2003 18:25:43 +0100
From: Andi Kleen <ak@muc.de>
Subject: Re: Linus rollup
Message-ID: <20030130172543.GA14213@averell>
References: <1043946568.10155.583.camel@dell_ss3.pdx.osdl.net> <Pine.LNX.4.33L2.0301300914500.4084-100000@dragon.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.33L2.0301300914500.4084-100000@dragon.pdx.osdl.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Randy.Dunlap" <rddunlap@osdl.org>
Cc: Stephen Hemminger <shemminger@osdl.org>, Andrea Arcangeli <andrea@suse.de>, Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@digeo.com>, David Miller <davem@redhat.com>, rmk@arm.linux.org.uk, ak@muc.de, davidm@napali.hpl.hp.com, anton@samba.org, linux-mm@kvack.org, rth@twiddle.net
List-ID: <linux-mm.kvack.org>

> You can follow Andrea's suggestion and call it a kaos_lock
> (for Keith Owens).

How about just seq_lock (sequence lock) ? 

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
