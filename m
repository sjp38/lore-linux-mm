Date: Thu, 31 Jan 2008 19:01:44 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 1/3] mmu_notifier: Core code
In-Reply-To: <20080201024742.GD26420@sgi.com>
Message-ID: <Pine.LNX.4.64.0801311852140.6272@schroedinger.engr.sgi.com>
References: <20080131045750.855008281@sgi.com> <20080131045812.553249048@sgi.com>
 <20080201023113.GB26420@sgi.com> <Pine.LNX.4.64.0801311838070.26594@schroedinger.engr.sgi.com>
 <20080201024742.GD26420@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Andrea Arcangeli <andrea@qumranet.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Thu, 31 Jan 2008, Robin Holt wrote:

> Both xpmem and GRU have means of removing their context seperate from
> process termination.  XPMEMs is by closing the fd, I believe GRU is
> the same.  In the case of XPMEM, we are able to acquire the mmap_sem.
> For GRU, I don't think it is possible, but I do not remember the exact
> reason.

For any action initiated from user space you will not hold mmap sem. So 
you can call the unregister function. Then you need to do a 
synchronize_rcu before freeing the structures.

It is also possible to shut this down outside via f.e. a control thread. 
The control thread can acquire mmap_sem and then unregister the notifier.

Am I missing something?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
