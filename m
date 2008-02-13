From: Jesse Barnes <jbarnes@virtuousgeek.org>
Subject: Re: Demand paging for memory regions
Date: Wed, 13 Feb 2008 15:48:49 -0800
References: <866658.37093.qm@web32510.mail.mud.yahoo.com>
In-Reply-To: <866658.37093.qm@web32510.mail.mud.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200802131548.50016.jbarnes@virtuousgeek.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanojsarcar@yahoo.com>
Cc: Christoph Lameter <clameter@sgi.com>, Christian Bell <christian.bell@qlogic.com>, Jason Gunthorpe <jgunthorpe@obsidianresearch.com>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <andrea@qumranet.com>, a.p.zijlstra@chello.nl, izike@qumranet.com, Roland Dreier <rdreier@cisco.com>, steiner@sgi.com, linux-kernel@vger.kernel.org, avi@qumranet.com, linux-mm@kvack.org, daniel.blueman@quadrics.com, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, Andrew Morton <akpm@linux-foundation.org>, kvm-devel@lists.sourceforge.net, Dave Airlie <airlied@linux.ie>
List-ID: <linux-mm.kvack.org>

On Wednesday, February 13, 2008 3:43 pm Kanoj Sarcar wrote:
> Oh ok, yes, I did see the discussion on this; sorry I
> missed it. I do see what notifiers bring to the table
> now (without endorsing it :-)).
>
> An orthogonal question is this: is IB/rdma the only
> "culprit" that elevates page refcounts? Are there no
> other subsystems which do a similar thing?
>
> The example I am thinking about is rawio (Oracle's
> mlock'ed SHM regions are handed to rawio, isn't it?).
> My understanding of how rawio works in Linux is quite
> dated though ...

We're doing something similar in the DRM these days...  We need big chunks of 
memory to be pinned so that the GPU can operate on them, but when the 
operation completes we can allow them to be swappable again.  I think with 
the current implementation, allocations are always pinned, but we'll 
definitely want to change that soon.

Dave?

Jesse

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
