Date: Tue, 07 Oct 2008 14:08:25 -0700 (PDT)
Message-Id: <20081007.140825.40261432.davem@davemloft.net>
Subject: Re: [patch][rfc] ddds: "dynamic dynamic data structure" algorithm,
 for adaptive dcache hash table sizing
From: David Miller <davem@davemloft.net>
In-Reply-To: <20081007064834.GA5959@wotan.suse.de>
References: <20081007064834.GA5959@wotan.suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Nick Piggin <npiggin@suse.de>
Date: Tue, 7 Oct 2008 08:48:34 +0200
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-netdev@vger.kernel.org, paulmck@us.ibm.com
List-ID: <linux-mm.kvack.org>

> I'm cc'ing netdev because Dave did express some interest in using this for
> some networking hashes, and network guys in general are pretty cluey when it
> comes to hashes and such ;)

Interesting stuff.

Paul, many months ago, forwarded to me a some work done by Josh
Triplett called "rcuhashbash" which had similar objectives.  He did
post it to linux-kernel, and perhaps even your ideas are inspired by
his work, I don't know. :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
