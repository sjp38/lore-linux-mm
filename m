Date: Fri, 1 Feb 2008 11:17:08 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Extending mmu_notifiers to handle __xip_unmap in a sleepable
 context?
In-Reply-To: <20080201115841.GM26420@sgi.com>
Message-ID: <Pine.LNX.4.64.0802011115180.18163@schroedinger.engr.sgi.com>
References: <20080201050439.009441434@sgi.com> <20080201115841.GM26420@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Andrea Arcangeli <andrea@qumranet.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Fri, 1 Feb 2008, Robin Holt wrote:

> Currently, it is calling mmu_notifier _begin and _end under the
> i_mmap_lock.  I _THINK_ the following will make it so we could support
> __xip_unmap (although I don't recall ever seeing that done on ia64 and
> don't even know what the circumstances are for its use).

Its called under lock yes.

The problem with this fix is that we currently have the requirement that 
the rmap invalidate_all call requires the pagelock to be held. That is not 
the case here. So I used _begin/_end to skirt the issue.

If you do not need the Pagelock to be held (it holds off modifications on 
the page!) then we are fine.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
