Subject: Re: [PATCH] strict VM overcommit for stock 2.4
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
In-Reply-To: <1027018340.1086.134.camel@sinai>
References: <Pine.LNX.4.30.0207181930170.30902-100000@divine.city.tvnet.hu>
	<1027022323.8154.38.camel@irongate.swansea.linux.org.uk>
	<1027018340.1086.134.camel@sinai>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 18 Jul 2002 21:52:12 +0100
Message-Id: <1027025532.8154.44.camel@irongate.swansea.linux.org.uk>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robert Love <rml@tech9.net>
Cc: Szakacsits Szabolcs <szaka@sienet.hu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> On Thu, 2002-07-18 at 12:58, Alan Cox wrote:
> 
> > Adjusting the percentages to have a root only zone is doable. It helps
> > in some conceivable cases but not all. Do people think its important, if
> > so I'll add it
> 
> Changing the rules would be easy, but you would need to make the
> accounting check for root vs non-root and keep track accordingly. 
> Admittedly not hard but not entirely pretty either.
> 
> I still contend the issues are not related.  It would make more sense to
> me to do resource limits to solve this problem - rlimits are something
> Rik has on his TODO and supposedly easy to add to rmap.

rmap supports rlimit AS which gives you paging control. Neither of them
support workload management or partitioned accounting of any kind. That
would need the beancounter patches resurrecting.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
