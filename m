Date: Wed, 3 Nov 2004 08:44:32 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH] Use MPOL_INTERLEAVE for tmpfs files
In-Reply-To: <239530000.1099435919@flay>
Message-ID: <Pine.LNX.4.44.0411030826310.6096-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Brent Casavant <bcasavan@sgi.com>, Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2 Nov 2004, Martin J. Bligh wrote:
> 
> Another way might be a tmpfs mount option ... I'd prefer that to a sysctl
> personally, but maybe others wouldn't. Hugh, is that nuts?

Only nuts if I am, I was going to suggest the same: the sysctl idea seems
very inadequate; a mount option at least allows the possibility of having
different tmpfs files allocated with different policies at the same time.

But I'm not usually qualified to comment on NUMA matters, and my tmpfs
maintenance shouldn't be allowed to get in the way of progress.  Plus
I've barely been attending in recent days: back to normality tomorrow.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
