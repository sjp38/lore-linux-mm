Date: Wed, 27 Feb 2008 16:24:53 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [kvm-devel] [PATCH] mmu notifiers #v7
In-Reply-To: <20080228002121.GC8091@v2.random>
Message-ID: <Pine.LNX.4.64.0802271624170.15965@schroedinger.engr.sgi.com>
References: <20080219231157.GC18912@wotan.suse.de> <20080220010941.GR7128@v2.random>
 <20080220103942.GU7128@v2.random> <20080221045430.GC15215@wotan.suse.de>
 <20080221144023.GC9427@v2.random> <20080221161028.GA14220@sgi.com>
 <20080227192610.GF28483@v2.random> <Pine.LNX.4.64.0802271503050.13186@schroedinger.engr.sgi.com>
 <20080227234317.GM28483@v2.random> <Pine.LNX.4.64.0802271605480.15667@schroedinger.engr.sgi.com>
 <20080228002121.GC8091@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Nick Piggin <npiggin@suse.de>, Steve Wise <swise@opengridcomputing.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Jack Steiner <steiner@sgi.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, daniel.blueman@quadrics.com, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu, 28 Feb 2008, Andrea Arcangeli wrote:

> I'm not suggesting not to address the issues, just that those issues
> requires VM core changes, and likely those changes should be
> switchable under a CONFIG_XPMEM, so I see no reason to delay the mmu
> notifier until those changes are done and merged too. It's kind of a
> separate problem.

No its the core problem of the mmu notifier. It needs to be usable for a 
lot of scenarios.

 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
