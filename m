Date: Tue, 07 Oct 2008 14:05:09 -0700 (PDT)
Message-Id: <20081007.140509.48442086.davem@davemloft.net>
Subject: Re: [patch][rfc] ddds: "dynamic dynamic data structure" algorithm,
 for adaptive dcache hash table sizing (resend)
From: David Miller <davem@davemloft.net>
In-Reply-To: <20081007080656.GB16143@wotan.suse.de>
References: <20081007070225.GB5959@wotan.suse.de>
	<48EB11BB.2060704@cosmosbay.com>
	<20081007080656.GB16143@wotan.suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Nick Piggin <npiggin@suse.de>
Date: Tue, 7 Oct 2008 10:06:56 +0200
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: dada1@cosmosbay.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, paulmck@us.ibm.com
List-ID: <linux-mm.kvack.org>

> Hmm, that is interesting. What are the exact semantics of this rt_cache
> file?

It dumps the whole set of elements in the routing cache hash table.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
