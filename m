Date: Thu, 30 Jan 2003 02:35:22 +0100
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: Linus rollup
Message-ID: <20030130013522.GP1237@dualathlon.random>
References: <20030129022617.62800a6e.akpm@digeo.com> <1043879752.10150.387.camel@dell_ss3.pdx.osdl.net> <20030129151206.269290ff.akpm@digeo.com> <20030129.163034.130834202.davem@redhat.com> <20030129172743.1e11d566.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030129172743.1e11d566.akpm@digeo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: "David S. Miller" <davem@redhat.com>, shemminger@osdl.org, rmk@arm.linux.org.uk, ak@muc.de, davidm@napali.hpl.hp.com, anton@samba.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 29, 2003 at 05:27:43PM -0800, Andrew Morton wrote:
> @@ -82,11 +85,12 @@ static inline int fr_write_trylock(frloc
>  
>  	if (ret) {
>  		++rw->pre_sequence;
> -		wmb();
> +		mb();
>  	}

this isn't needed


if we hold the spinlock, the serialized memory can't be change under us,
so there's no need to put a read barrier, we only care that pre_sequence
is visible before the chagnes are visible and before post_sequence is
visible, hence only wmb() (after spin_lock and pre_sequence++) is
needed there and only rmb() is needed in the read-side.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
