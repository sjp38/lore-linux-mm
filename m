Message-ID: <45E06A86.2060408@trash.net>
Date: Sat, 24 Feb 2007 17:40:38 +0100
From: Patrick McHardy <kaber@trash.net>
MIME-Version: 1.0
Subject: Re: [PATCH 18/29] netfilter: notify about NF_QUEUE vs	emergency	skbs
References: <20070221144304.512721000@taijtu.programming.kicks-ass.net>	 <20070221144843.299254000@taijtu.programming.kicks-ass.net>	 <45E05954.8050204@trash.net> <1172332010.28579.6.camel@lappy>	 <45E064FF.8010000@trash.net> <1172333937.6374.47.camel@twins>
In-Reply-To: <1172333937.6374.47.camel@twins>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, Trond Myklebust <trond.myklebust@fys.uio.no>, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

Peter Zijlstra wrote:
> On Sat, 2007-02-24 at 17:17 +0100, Patrick McHardy wrote:
> 
> 
>>I don't really see why
>>queueing is special though, dropping the packets in the ruleset
>>will break things just as well, as will routing them to a blackhole.
>>I guess the user just needs to be smart enough not to do this.
> 
> 
> Its user-space and no emergency packet may rely on user-space because it
> most likely is needed to maintain user-space.

I believe I might have misunderstood the intention of this patch.

Assuming the user is smart enough not to queue packets destined
to a SOCK_VMIO socket, are you worried about unrelated packets
allocated from the emergency reserve not getting freed fast
enough because they're sitting in a queue? In that case simply
dropping the packets would be fine I guess.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
