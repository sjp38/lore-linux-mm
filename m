Date: Wed, 22 Aug 2007 15:39:51 -0700 (PDT)
Message-Id: <20070822.153951.67894132.davem@davemloft.net>
Subject: Re: [PATCH] Do not fail if we cannot register a slab with sysfs
From: David Miller <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.64.0708221512260.17282@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0708221512260.17282@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Christoph Lameter <clameter@sgi.com>
Date: Wed, 22 Aug 2007 15:14:49 -0700 (PDT)
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Do not BUG() if we cannot register a slab with sysfs. Just print an
> error. The only consequence of not registering is that the slab cache
> is not visible via /sys/slab. A BUG() may not be visible that
> early during boot and we have had multiple issues here already.
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>

Acked-by: David S. Miller <davem@davemloft.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
