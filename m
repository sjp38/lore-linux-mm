Date: Mon, 1 Nov 2004 16:15:41 -0800 (PST)
From: Christoph Lameter <christoph@lameter.com>
Subject: Re: [PATCH 0/7] abstract pagetable locking and pte updates
In-Reply-To: <20041029074607.GA12934@holomorphy.com>
Message-ID: <Pine.LNX.4.58.0411011612060.8399@server.graphe.net>
References: <4181EF2D.5000407@yahoo.com.au> <20041029074607.GA12934@holomorphy.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 29 Oct 2004, William Lee Irwin III wrote:

> On Fri, Oct 29, 2004 at 05:20:13PM +1000, Nick Piggin wrote:
> > Known issues: Hugepages, nonlinear pages haven't been looked at
> > and are quite surely broken. TLB flushing (gather/finish) runs
> > without the page table lock, which will break at least SPARC64.
> > Additional atomic ops in copy_page_range slow down lmbench fork
> > by 7%.
>
> This raises the rather serious question of what you actually did
> besides rearranging Lameter's code. It had all the same problems;
> resolving them is a prerequisite to going anywhere with all this.

Could you be specific as to the actual problems? I have worked through
several archs over time and my code offers a fallback to the use of the
page_table_lock if an arch does not provide the necessary atomic ops.
So what are the issues with my code? I fixed the PAE code based on Nick's
work. AFAIK this was the only known issue.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
