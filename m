Date: Fri, 6 Aug 2004 07:07:14 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [proc.txt] Fix /proc/pid/statm documentation
Message-ID: <20040806140714.GG17188@holomorphy.com>
References: <1091754711.1231.2388.camel@cube> <20040806094037.GB11358@k3.hellgate.ch> <20040806104630.GA17188@holomorphy.com> <20040806120123.GA23081@k3.hellgate.ch> <20040806121118.GE17188@holomorphy.com> <20040806135756.GA21411@k3.hellgate.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040806135756.GA21411@k3.hellgate.ch>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roger Luethi <rl@hellgate.ch>
Cc: Albert Cahalan <albert@users.sf.net>, linux-kernel mailing list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 06 Aug 2004 05:11:18 -0700, William Lee Irwin III wrote:
>> Some of the 2.4 semantics just don't make sense. I would not find it
>> difficult to explain what I believe correct semantics to be in a written
>> document.

On Fri, Aug 06, 2004 at 03:57:56PM +0200, Roger Luethi wrote:
> IMO this is a must for such files (and be it only some comments above
> the code implementing them). I'm afraid that statm is carrying too much
> historical baggage, though -- you would add yet another interpretation
> of those 7 fields.
> Tools reading statm would have to be updated anyway, so I'd rather
> think about what could be done with a new (or just different) file.

Okay, could you write up a "specification" for what you want reported,
then I can cook up a new file or some such for you?

Thanks.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
