Date: Sat, 6 Nov 2004 18:25:47 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: removing mm->rss and mm->anon_rss from kernel?
Message-ID: <20041107022547.GK2890@holomorphy.com>
References: <20041106103103.GC2890@holomorphy.com> <418CAA44.3090007@yahoo.com.au> <20041106105314.GD2890@holomorphy.com> <418CB06F.1080405@yahoo.com.au> <20041106120624.GE2890@holomorphy.com> <418CBED7.6050609@yahoo.com.au> <20041106122355.GF2890@holomorphy.com> <418D7235.7010501@yahoo.com.au> <20041107011113.GJ2890@holomorphy.com> <418D8138.9080401@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <418D8138.9080401@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Christoph Lameter <clameter@sgi.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, linux-ia64@kernel.vger.org
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
>> Your purported "tests" have a rather obvious predetermined conclusion.
>> Some minute amount of overhead for normal machines will be exaggerated
>> in a supercomputer environment, and all of the detriments will be
>> carefully hidden by avoiding monitoring processes or monitoring only
>> low numbers of them.

On Sun, Nov 07, 2004 at 12:58:16PM +1100, Nick Piggin wrote:
> I thought Christoph would be very interested to see the worst cases in
> semi real world workloads that his systems actually run.
> I didn't realise this is part of a conspiracy to covertly back out all
> your work. Maybe Jeff Merkey is behind it, and you're the last freedom
> loving kernel hacker who won't sell out? ;)

\begin{vomit}
This attempt at humor, if it was such, inspired very little levity.
\end{vomit}

Moving on, I pushed the specific mechanisms for good reasons, and at
the very least attempt to maintain the code and watch for problematic
issues in the area of basic workload monitoring facilities in the
kernel, particularly when they pose catastrophic disruptions to
workloads. Basic respect for that effort and those needs would be much
appreciated. Though I did realize it was inadvertent, I was still
greatly annoyed.


William Lee Irwin III wrote:
>> Now to brace myself for another of your petty "last word" shenanigans.

On Sun, Nov 07, 2004 at 12:58:16PM +1100, Nick Piggin wrote:
> I tried to think up some witty remark to go here but couldn't.
> OK, sorry. Whatever I've done to offend you I didn't intend it. We don't
> always seem to be talking on the same level... Can we try to be more
> light hearted about things? I'm really not interested in shenanigans of
> any kind with you.

Yet you've already begun. In general this practice is meant to exhaust
the opposition in some debate, and when they fail to respond, claim
the silence as assent, to prevent an "unfavorable" conclusion of a
debate from being reached by refusing to allow the discussion to
conclude so long as its conclusion is unfavorable, and to discourage
future "challenges".

Please restrict your methods of patch promotion to technical ones as
opposed to rhetorical devices such as that.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
