Date: Thu, 14 Feb 2008 11:35:37 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [ofa-general] Re: Demand paging for memory regions
In-Reply-To: <866658.37093.qm@web32510.mail.mud.yahoo.com>
Message-ID: <Pine.LNX.4.64.0802141133430.477@schroedinger.engr.sgi.com>
References: <866658.37093.qm@web32510.mail.mud.yahoo.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanojsarcar@yahoo.com>
Cc: Christian Bell <christian.bell@qlogic.com>, Jason Gunthorpe <jgunthorpe@obsidianresearch.com>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <andrea@qumranet.com>, a.p.zijlstra@chello.nl, izike@qumranet.com, Roland Dreier <rdreier@cisco.com>, steiner@sgi.com, linux-kernel@vger.kernel.org, avi@qumranet.com, linux-mm@kvack.org, daniel.blueman@quadrics.com, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, Andrew Morton <akpm@linux-foundation.org>, kvm-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Wed, 13 Feb 2008, Kanoj Sarcar wrote:

> Oh ok, yes, I did see the discussion on this; sorry I
> missed it. I do see what notifiers bring to the table
> now (without endorsing it :-)).
> 
> An orthogonal question is this: is IB/rdma the only
> "culprit" that elevates page refcounts? Are there no
> other subsystems which do a similar thing?

Yes there are actually two projects by SGI that also ran into the same 
issue that motivated the work on this. One is XPmem which allows 
sharing of process memory between different Linux instances and then 
there is the GRU which is a kind of DMA engine. Then there is KVM and 
probably multiple other drivers.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
