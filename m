Date: Thu, 21 Feb 2008 06:02:23 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH] mmu notifiers #v6
Message-ID: <20080221050223.GD15215@wotan.suse.de>
References: <20080219084357.GA22249@wotan.suse.de> <20080219135851.GI7128@v2.random> <20080219231157.GC18912@wotan.suse.de> <20080220010941.GR7128@v2.random> <20080220103942.GU7128@v2.random> <20080220113313.GD11364@sgi.com> <20080220120324.GW7128@v2.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080220120324.GW7128@v2.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Robin Holt <holt@sgi.com>, akpm@linux-foundation.org, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On Wed, Feb 20, 2008 at 01:03:24PM +0100, Andrea Arcangeli wrote:
> If there's agreement that the VM should alter its locking from
> spinlock to mutex for its own good, then Christoph's
> one-config-option-fits-all becomes a lot more appealing (replacing RCU
> with a mutex in the mmu notifier list registration locking isn't my
> main worry and the non-sleeping-users may be ok to live with it).

Just from a high level view, in some cases we can just say that no we
aren't going to support this. And this may well be one of those cases.

The more constraints placed on the VM, the harder it becomes to
improve and adapt in future. And this seems like a pretty big restriction.
(especially if we can eg. work around it completely by having a special
purpose driver to get_user_pages on comm buffers as I suggested in the
other mail).

At any rate, I believe Andrea's patch really places minimal or no further
constraints than a regular CPU TLB (or the hash tables that some archs
implement). So we're kind of in 2 different leagues here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
