Date: Sat, 20 May 2000 08:52:21 +0200
From: Carlo Wood <carlo@alinoe.com>
Subject: VM and classzone
Message-ID: <20000520085221.A8294@a2000.nl>
References: <Pine.LNX.4.21.0005191204300.20142-100000@duckman.distro.conectiva> <Pine.LNX.4.21.0005190914440.1099-100000@inspiron.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.4.21.0005190914440.1099-100000@inspiron.random>; from andrea@suse.de on Fri, May 19, 2000 at 09:16:35AM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.rutgers.edu
Cc: linux-mm@kvack.org, torvalds@transmeta.com, riel@conectiva.com.br, andrea@suse.de
List-ID: <linux-mm.kvack.org>

On Fri, May 19, 2000 at 09:16:35AM -0700, Andrea Arcangeli wrote:
> On Fri, 19 May 2000, Rik van Riel wrote:
> 
> >varying loads (but that's orthagonal, except for the fact
> >that it would automagically solve the last 2 problems with
> >pre9-2 + quintela).
> 
> This make no sense to me. It it fixes two problems that doesn't mean it's
> not orthogonal.
> 
> I'm not sure about the problems you're talking about. And I'm not
> convinced that waiting I/O completation during shink_mmap will be
> successfully.
> 
> Andrea

I know I am pretty new to this list, but allow me to put
an observation into a summary:

The were problems with VM - also known as 'kswapd problem'
because it showed itself mainly as a stall of the kernel
while kswapd was consuming often, and a lot, cpu.

Andrea Arcangeli has been working on what is known as the
"class zone" patch(es) - which is a structural redesign
related to how VM works (correct me if I am wrong).
Linus didn't add this to the kernel because he thinks that
Andreas (re)design has flaws.

Rik van Riel also worked on VM, but more from the point of
view of 'how to fix the kswapd bug', and he succeeded
(at least partly, perhaps completely): reports have been
posted that this bug is now gone - which is also my own
humble observation.

Nevertheless, the discussion about Andreas design continues
as if it had to do with the bug - which is not true (I agree
with Linus on this).

In order to come to a solution, I'd like to suggest the
following:

- Linus makes a short list of what he thinks are the
  pros and cons of Andreas design, so it is more clear
  to Andrea what is the reason for the rejection so far;
  and if his design will ever make a chance to get into
  the kernel at all.
- If there is chance that after possible improvements
  the patch will be added to a future kernel, then a series
  of benchmark tests if proposed by all parties that will
  produce *numbers* - so we will be able to actually see
  the impact of Andreas patch (with and without).

$0.02 of a neutral party,

-- 
Carlo Wood <carlo@alinoe.com>
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
