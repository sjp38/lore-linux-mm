Date: Tue, 12 Aug 2003 17:36:20 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH] Deprecate /proc/#/statm
Message-ID: <20030813003620.GG3170@holomorphy.com>
References: <20030811090213.GA11939@k3.hellgate.ch> <20030811160222.GE3170@holomorphy.com> <20030811215235.GB13180@k3.hellgate.ch> <20030811221646.GF3170@holomorphy.com> <20030812104046.GA6606@k3.hellgate.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030812104046.GA6606@k3.hellgate.ch>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roger Luethi <rl@hellgate.ch>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Mon, 11 Aug 2003 15:16:46 -0700, William Lee Irwin III wrote:
>> Not entirely unreasonable.

On Tue, Aug 12, 2003 at 12:40:46PM +0200, Roger Luethi wrote:
> Alright. We have established that /proc/#/statm has been useless at least
> since 2.4. Procps doesn't even bother reading it.
> I propose this very non-invasive patch for 2.6. It replaces all values
> printed in statm (all of which are either redundant or bogus) with 0s (for
> kblockd and others statm is a line of zeroes already). IMO the real surgery
> should happen in 2.7.
> Comments? Andrew?

Best to just delete the code instead of the #if 0


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
