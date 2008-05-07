Date: Wed, 7 May 2008 17:00:15 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH 01 of 12] Core of mmu notifiers
Message-ID: <20080507150014.GI8362@duo.random>
References: <20080424153943.GJ24536@duo.random> <20080424174145.GM24536@duo.random> <20080426131734.GB19717@sgi.com> <20080427122727.GO9514@duo.random> <Pine.LNX.4.64.0804281332030.31163@schroedinger.engr.sgi.com> <20080429001052.GA8315@duo.random> <Pine.LNX.4.64.0804281819020.2502@schroedinger.engr.sgi.com> <20080429153052.GE8315@duo.random> <20080429155030.GB28944@sgi.com> <20080429160340.GG8315@duo.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080429160340.GG8315@duo.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, akpm@linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 29, 2008 at 06:03:40PM +0200, Andrea Arcangeli wrote:
> Christoph if you've interest in evolving anon-vma-sem and i_mmap_sem
> yourself in this direction, you're very welcome to go ahead while I

In case you didn't notice this already, for a further explanation of
why semaphores runs slower for small critical sections and why the
conversion from spinlock to rwsem should happen under a config option,
see the "AIM7 40% regression with 2.6.26-rc1" thread.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
