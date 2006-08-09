Date: Tue, 08 Aug 2006 22:55:37 -0700 (PDT)
Message-Id: <20060808.225537.112622421.davem@davemloft.net>
Subject: Re: [RFC][PATCH 8/9] 3c59x driver conversion
From: David Miller <davem@davemloft.net>
In-Reply-To: <44D977D8.5070306@google.com>
References: <20060808193447.1396.59301.sendpatchset@lappy>
	<44D9191E.7080203@garzik.org>
	<44D977D8.5070306@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Daniel Phillips <phillips@google.com>
Date: Tue, 08 Aug 2006 22:51:20 -0700
Return-Path: <owner-linux-mm@kvack.org>
To: phillips@google.com
Cc: jeff@garzik.org, a.p.zijlstra@chello.nl, netdev@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> Elaborate please.  Do you think that all drivers should be updated to
> fix the broken blockdev semantics, making NETIF_F_MEMALLOC redundant?
> If so, I trust you will help audit for it?

I think he's saying that he doesn't think your code is yet a
reasonable way to solve the problem, and therefore doesn't belong
upstream.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
