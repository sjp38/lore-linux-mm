Date: Mon, 1 Nov 2004 16:54:39 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH 0/7] abstract pagetable locking and pte updates
Message-ID: <20041102005439.GQ2583@holomorphy.com>
References: <4181EF2D.5000407@yahoo.com.au> <20041029074607.GA12934@holomorphy.com> <Pine.LNX.4.58.0411011612060.8399@server.graphe.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0411011612060.8399@server.graphe.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <christoph@lameter.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 29 Oct 2004, William Lee Irwin III wrote:
>> This raises the rather serious question of what you actually did
>> besides rearranging Lameter's code. It had all the same problems;
>> resolving them is a prerequisite to going anywhere with all this.

On Mon, Nov 01, 2004 at 04:15:41PM -0800, Christoph Lameter wrote:
> Could you be specific as to the actual problems? I have worked through
> several archs over time and my code offers a fallback to the use of the
> page_table_lock if an arch does not provide the necessary atomic ops.
> So what are the issues with my code? I fixed the PAE code based on Nick's
> work. AFAIK this was the only known issue.

Well, I'm not going to sit around and look for holes in this all day
(that should have been done by the author), however it's not a priori
true that decoupling locking surrounding tlb_flush_mmu() from pte
locking is correct.

The audits behind this need to be better.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
