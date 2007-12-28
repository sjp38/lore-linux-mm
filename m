Date: Thu, 27 Dec 2007 16:18:22 -0800 (PST)
Message-Id: <20071227.161822.262276105.davem@davemloft.net>
Subject: Re: [PATCH 08/10] Sparc64: Use generic percpu
From: David Miller <davem@davemloft.net>
In-Reply-To: <20071228001618.687461000@sgi.com>
References: <20071228001617.597161000@sgi.com>
	<20071228001618.687461000@sgi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: travis@sgi.com
Date: Thu, 27 Dec 2007 16:16:25 -0800
Return-Path: <owner-linux-mm@kvack.org>
To: travis@sgi.com
Cc: akpm@linux-foundation.org, clameter@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> Sparc64 has a way of providing the base address for the per cpu area of the
> currently executing processor in a global register.
> 
> Sparc64 also provides a way to calculate the address of a per cpu area
> from a base address instead of performing an array lookup.
> 
> Cc: David Miller <davem@davemloft.net>
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> Signed-off-by: Mike Travis <travis@sgi.com>

Acked-by: David S. Miller <davem@davemloft.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
