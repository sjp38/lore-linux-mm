Message-ID: <3E3884DA.9060600@pobox.com>
Date: Wed, 29 Jan 2003 20:50:18 -0500
From: Jeff Garzik <jgarzik@pobox.com>
MIME-Version: 1.0
Subject: Re: Linus rollup
References: <20030129022617.62800a6e.akpm@digeo.com>	<1043879752.10150.387.camel@dell_ss3.pdx.osdl.net>	<20030129151206.269290ff.akpm@digeo.com>	<20030129.163034.130834202.davem@redhat.com>	<20030129172743.1e11d566.akpm@digeo.com>	<20030130013522.GP1237@dualathlon.random> <20030129180054.03ac0d48.akpm@digeo.com>
In-Reply-To: <20030129180054.03ac0d48.akpm@digeo.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Andrea Arcangeli <andrea@suse.de>, davem@redhat.com, shemminger@osdl.org, rmk@arm.linux.org.uk, ak@muc.de, davidm@napali.hpl.hp.com, anton@samba.org, linux-mm@kvack.org, rth@twiddle.net
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> #ifndef __LINUX_FRLOCK_H
> #define __LINUX_FRLOCK_H
> 
> /*
>  * Fast read-write spinlocks.


Can we please pick a unique name whose meaning will not change over 
time?  Even "andre[wa]_rw_lock" would be better, because its meaning is 
not tied to performance at this specific point in time, on today's ia32 
flavor-of-the-month.

If we discover even-yet-faster read-write spinlocks tomorrow, this name 
is going to become a joke :)

	Jeff



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
