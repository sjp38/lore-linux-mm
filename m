Date: Mon, 30 Apr 2007 15:42:15 -0700 (PDT)
Message-Id: <20070430.154215.97292561.davem@davemloft.net>
Subject: Re: vm changes from linux-2.6.14 to linux-2.6.15
From: David Miller <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.61.0704302329390.3178@mtfhpc.demon.co.uk>
References: <20070430145414.88fda272.akpm@linux-foundation.org>
	<20070430.150407.07642146.davem@davemloft.net>
	<Pine.LNX.4.61.0704302329390.3178@mtfhpc.demon.co.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Mark Fortescue <mark@mtfhpc.demon.co.uk>
Date: Mon, 30 Apr 2007 23:33:13 +0100 (BST)
Return-Path: <owner-linux-mm@kvack.org>
To: mark@mtfhpc.demon.co.uk
Cc: akpm@linux-foundation.org, andrea@suse.de, wli@holomorphy.com, sparclinux@vger.kernel.org, linuxppc-dev@ozlabs.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Is this just sun4c or does it affect other sparc32 architectures.

Only sun4c.

srmmu's update_mmu_cache() is basically a NOP.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
