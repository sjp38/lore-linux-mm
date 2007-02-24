Subject: Re: [PATCH 18/29] netfilter: notify about NF_QUEUE vs
	emergency	skbs
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <45E064FF.8010000@trash.net>
References: <20070221144304.512721000@taijtu.programming.kicks-ass.net>
	 <20070221144843.299254000@taijtu.programming.kicks-ass.net>
	 <45E05954.8050204@trash.net> <1172332010.28579.6.camel@lappy>
	 <45E064FF.8010000@trash.net>
Content-Type: text/plain
Date: Sat, 24 Feb 2007 17:18:56 +0100
Message-Id: <1172333937.6374.47.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Patrick McHardy <kaber@trash.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, Trond Myklebust <trond.myklebust@fys.uio.no>, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

On Sat, 2007-02-24 at 17:17 +0100, Patrick McHardy wrote:

> I don't really see why
> queueing is special though, dropping the packets in the ruleset
> will break things just as well, as will routing them to a blackhole.
> I guess the user just needs to be smart enough not to do this.

Its user-space and no emergency packet may rely on user-space because it
most likely is needed to maintain user-space.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
