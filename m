Date: Wed, 29 Jan 2003 17:52:32 -0800
From: Richard Henderson <rth@twiddle.net>
Subject: Re: Linus rollup
Message-ID: <20030129175232.A19969@twiddle.net>
References: <20030129022617.62800a6e.akpm@digeo.com> <1043879752.10150.387.camel@dell_ss3.pdx.osdl.net> <20030129151206.269290ff.akpm@digeo.com> <20030129.163034.130834202.davem@redhat.com> <20030129172743.1e11d566.akpm@digeo.com> <20030130013522.GP1237@dualathlon.random> <20030129180054.03ac0d48.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030129180054.03ac0d48.akpm@digeo.com>; from akpm@digeo.com on Wed, Jan 29, 2003 at 06:00:54PM -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Andrea Arcangeli <andrea@suse.de>, davem@redhat.com, shemminger@osdl.org, rmk@arm.linux.org.uk, ak@muc.de, davidm@napali.hpl.hp.com, anton@samba.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 29, 2003 at 06:00:54PM -0800, Andrew Morton wrote:
> Andrea Arcangeli <andrea@suse.de> wrote:
> > if we hold the spinlock, the serialized memory can't be change under us,
> > so there's no need to put a read barrier, we only care that pre_sequence
> > is visible before the chagnes are visible and before post_sequence is
> > visible, hence only wmb() (after spin_lock and pre_sequence++) is
> > needed there and only rmb() is needed in the read-side.

Hmm.  Perhaps I was confused about how these things are intended
to be used.  If indeed the writer doesn't care about the order
in which pre/post_sequence are accessed, then wmb is sufficient
to keep their updates ordered.



r~
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
