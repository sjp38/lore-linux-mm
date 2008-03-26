Date: Tue, 25 Mar 2008 17:31:46 -0700 (PDT)
Message-Id: <20080325.173146.238342309.davem@davemloft.net>
Subject: Re: larger default page sizes...
From: David Miller <davem@davemloft.net>
In-Reply-To: <87od925o15.wl%peter@chubb.wattle.id.au>
References: <87tziu5q37.wl%peter@chubb.wattle.id.au>
	<20080325.164927.249210766.davem@davemloft.net>
	<87od925o15.wl%peter@chubb.wattle.id.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Wed, 26 Mar 2008 11:25:58 +1100
Return-Path: <owner-linux-mm@kvack.org>
To: peterc@gelato.unsw.edu.au
Cc: clameter@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, torvalds@linux-foundation.org, ianw@gelato.unsw.edu.au
List-ID: <linux-mm.kvack.org>

> That depends on the access pattern.

Absolutely.

FWIW, I bet it helps enormously for gcc which, even for
small compiles, swims around chaotically in an 8MB pool
of GC'd memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
