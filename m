Date: Thu, 21 Nov 2002 17:08:53 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.5.48-mm1
Message-ID: <20021122010853.GI11776@holomorphy.com>
References: <Pine.LNX.4.44.0211191338590.1596-100000@localhost.localdomain> <Pine.LNX.3.96.1021121160056.10456D-100000@gatekeeper.tmr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.3.96.1021121160056.10456D-100000@gatekeeper.tmr.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bill Davidsen <davidsen@tmr.com>
Cc: Hugh Dickins <hugh@veritas.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Nov 21, 2002 at 04:04:25PM -0500, Bill Davidsen wrote:
> This is purely a performance decision. If you want to avoid bad latency on
> reads then you have to throttle writes. The loop_thread will make the
> system just as slow as a user application writing the same number of
> pages.
> If you want io scheduling you will deliberately slow writes to let reads
> happen in reasonable time. And vice-versa I imagine, although I don't
> think I've seen that case.

Not entirely so. This is just a scheduling decision that has to
discriminate between blocking and nonblocking requests and prevent
starvation of the blocking requests. Write throttling is an
oversimplification that functions poorly.


Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
