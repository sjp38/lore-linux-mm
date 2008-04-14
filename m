Date: Mon, 14 Apr 2008 14:33:30 -0700 (PDT)
Message-Id: <20080414.143330.69128651.davem@davemloft.net>
Subject: Re: sparc64: Fix NR_PAGEFLAGS check V2
From: David Miller <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.64.0804141139270.7130@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0804141139270.7130@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Christoph Lameter <clameter@sgi.com>
Date: Mon, 14 Apr 2008 11:40:28 -0700 (PDT)
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Update checks to make sure that we can place the cpu number in the
> upper portion of the page flags.
> 
> Its okay if we use less than 32 page flags. There can only be a problem if
> the page flags grow beyond 32 bits to reach into the area reserved for the
> cpu number.
> 
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Christoph Lameter <clameter@sgi.com>

Acked-by: David S. Miller <davem@davemloft.net>

Looks good.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
