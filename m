Date: Thu, 30 Jan 2003 09:23:29 -0800 (PST)
From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: Linus rollup
In-Reply-To: <20030130172543.GA14213@averell>
Message-ID: <Pine.LNX.4.33L2.0301300922590.4084-100000@dragon.pdx.osdl.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@muc.de>
Cc: Stephen Hemminger <shemminger@osdl.org>, Andrea Arcangeli <andrea@suse.de>, Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@digeo.com>, David Miller <davem@redhat.com>, rmk@arm.linux.org.uk, davidm@napali.hpl.hp.com, anton@samba.org, linux-mm@kvack.org, rth@twiddle.net
List-ID: <linux-mm.kvack.org>

On Thu, 30 Jan 2003, Andi Kleen wrote:

| > You can follow Andrea's suggestion and call it a kaos_lock
| > (for Keith Owens).
|
| How about just seq_lock (sequence lock) ?

Hey, that makes some sense...

-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
