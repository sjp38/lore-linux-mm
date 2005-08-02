Date: Tue, 02 Aug 2005 15:39:04 -0700
From: "Martin J. Bligh" <mbligh@mbligh.org>
Reply-To: "Martin J. Bligh" <mbligh@mbligh.org>
Subject: Re: Network vm deadlock... solution?
Message-ID: <16580000.1123022344@[10.10.2.4]>
In-Reply-To: <20050802214340.GA6309@electric-eye.fr.zoreil.com>
References: <200508020654.32693.phillips@istop.com> <1123003658.3754.28.camel@w-sridhar2.beaverton.ibm.com> <200508030613.37359.phillips@istop.com> <20050802214340.GA6309@electric-eye.fr.zoreil.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Francois Romieu <romieu@fr.zoreil.com>, Daniel Phillips <phillips@istop.com>
Cc: Sridhar Samudrala <sri@us.ibm.com>, netdev@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


--Francois Romieu <romieu@fr.zoreil.com> wrote (on Tuesday, August 02, 2005 23:43:40 +0200):

> Daniel Phillips <phillips@istop.com> :
> [...]
>> A point on memory pressure: here, we are not talking about the continuous 
>> state of running under heavy load, but rather the microscopically short 
>> periods where not a single page of memory is available to normal tasks.  It 
>> is when a block IO event happens to land inside one of those microscopically 
>> short periods that we run into problems.
> 
> You suggested in a previous message to use an emergency allocation pool at
> the driver level. Afaik, 1) the usual network driver can already buffer a
> bit with its Rx descriptor ring and 2) it more or less tries to refill it
> each time napi issues its ->poll() method. So it makes me wonder:
> - have you collected evidence that the drivers actually run out of memory
>   in the (microscopical) situation you describe ?

There's other situations where it does (ie swap device dies, etc).

> - instead of modifying each and every driver to be vm aware, why don't
>   you hook in net_rx_action() when memory starts to be low ?
> 
> Btw I do not get what the mempool/GFP_CRITICAL idea buys: it seems redundant
> with the threshold ("if (memory_pressure)") used in the Rx path to decide
> that memory is low.

It's send-side, not receive.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
