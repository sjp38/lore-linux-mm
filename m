Date: Wed, 27 Feb 2008 16:42:32 -0600
From: Jack Steiner <steiner@sgi.com>
Subject: Re: [patch 2/6] mmu_notifier: Callbacks to invalidate address ranges
Message-ID: <20080227224232.GA18581@sgi.com>
References: <20080215064859.384203497@sgi.com> <20080215064932.620773824@sgi.com> <200802201008.49933.nickpiggin@yahoo.com.au> <Pine.LNX.4.64.0802271424390.13186@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0802271424390.13186@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, akpm@linux-foundation.org, Andrea Arcangeli <andrea@qumranet.com>, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

>  
> > Also, what we are going to need here are not skeleton drivers
> > that just do all the *easy* bits (of registering their callbacks),
> > but actual fully working examples that do everything that any
> > real driver will need to do. If not for the sanity of the driver
> > writer, then for the sanity of the VM developers (I don't want
> > to have to understand xpmem or infiniband in order to understand
> > how the VM works).
> 
> There are 3 different drivers that can already use it but the code is 
> complex and not easy to review. Skeletons are easy to allow people to get 
> started with it.


I posted the full GRU driver late last week. It is a lot of
code & somewhat difficult to understand w/o access to full chip
specs (sorry). The code is fairly well commented &  the
parts related to TLB management should be understandable.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
