Date: Tue, 25 Mar 2008 21:36:02 -0700 (PDT)
Message-Id: <20080325.213602.193698359.davem@davemloft.net>
Subject: Re: larger default page sizes...
From: David Miller <davem@davemloft.net>
In-Reply-To: <47E9CE00.7060106@fc.hp.com>
References: <ed5aea430803251734u70f199w10951bc4f0db6262@mail.gmail.com>
	<87lk465mks.wl%peter@chubb.wattle.id.au>
	<47E9CE00.7060106@fc.hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: John Marvin <jsm@fc.hp.com>
Date: Tue, 25 Mar 2008 22:16:00 -0600
Return-Path: <owner-linux-mm@kvack.org>
To: jsm@fc.hp.com
Cc: linux-ia64@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> 1) There was no easy way of determining what size the long format vhpt cache 
> should be automatically, and changing it dynamically would be too painful. 
> Different workloads performed better with different size vhpt caches.

This is exactly what sparc64 does btw, dynamic TLB miss hash table
sizing based upon task RSS

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
