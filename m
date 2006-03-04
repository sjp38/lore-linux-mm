Date: Sat, 4 Mar 2006 12:08:50 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: numa_maps update
In-Reply-To: <200603040559.16666.ak@suse.de>
Message-ID: <Pine.LNX.4.64.0603041206260.18435@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0603030846170.13932@schroedinger.engr.sgi.com>
 <20060304010708.31697f71.akpm@osdl.org> <200603040559.16666.ak@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Andrew Morton <akpm@osdl.org>, hugh@veritas.com, linux-mm@kvack.org, mtk-manpages@gmx.net
List-ID: <linux-mm.kvack.org>

On Sat, 4 Mar 2006, Andi Kleen wrote:

> > What will be the userspace impact (ie: breakage) due to this change?
> 
> It will at least break the manpages I think. But I suspect/hope no user space
> is using it yet because it was only added recently.

There are no manpages for numa_maps yet. The only uses I know of currently 
is users doing "cat /proc/<pid>/numa_maps".

> > What bizarre layout!
> 
> The 16 space indents?

The issue was the blank lines in there?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
