Date: Wed, 09 Aug 2006 17:01:18 -0700 (PDT)
Message-Id: <20060809.170118.116356057.davem@davemloft.net>
Subject: Re: [RFC][PATCH 2/9] deadlock prevention core
From: David Miller <davem@davemloft.net>
In-Reply-To: <1155140394.12225.88.camel@twins>
References: <1155132440.12225.70.camel@twins>
	<20060809161816.GA14627@postel.suug.ch>
	<1155140394.12225.88.camel@twins>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Wed, 09 Aug 2006 18:19:54 +0200
Return-Path: <owner-linux-mm@kvack.org>
To: a.p.zijlstra@chello.nl
Cc: tgraf@suug.ch, phillips@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> disregards this part from -v2 then :-(

And please don't do arbitrary cleanups in your patches like
how you reformatted all of the NETIF_F_* macro values.

Do things like that as a seperate change in your set of
patches so it's easier for people to review your work.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
