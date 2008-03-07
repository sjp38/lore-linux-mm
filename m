Date: Fri, 7 Mar 2008 12:03:42 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] 4/4 i_mmap_lock spinlock2rwsem (#v9 was 1/4)
In-Reply-To: <20080307155244.GF24114@v2.random>
Message-ID: <Pine.LNX.4.64.0803071201000.6815@schroedinger.engr.sgi.com>
References: <20080303213707.GA8091@v2.random> <20080303220502.GA5301@v2.random>
 <47CC9B57.5050402@qumranet.com> <Pine.LNX.4.64.0803032327470.9642@schroedinger.engr.sgi.com>
 <20080304133020.GC5301@v2.random> <Pine.LNX.4.64.0803041059110.13957@schroedinger.engr.sgi.com>
 <20080304222030.GB8951@v2.random> <Pine.LNX.4.64.0803041422070.20821@schroedinger.engr.sgi.com>
 <20080307151722.GD24114@v2.random> <20080307152328.GE24114@v2.random>
 <20080307155244.GF24114@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Jack Steiner <steiner@sgi.com>, Nick Piggin <npiggin@suse.de>, akpm@linux-foundation.org, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Fri, 7 Mar 2008, Andrea Arcangeli wrote:

> I didn't look into this but it shows how it would be risky to make
> this change in .25. It's a bit strange that the bugcheck triggers

Yes this was never intended for .25. I think we need to split this into a 
copule of patches. One needs to get rid of the spinlock dropping, then one 
that deals with the read concurrency issues and finally one that converts 
the spinlock. Thanks for looking at it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
