Date: Thu, 05 Oct 2006 13:19:43 -0700 (PDT)
Message-Id: <20061005.131943.11597704.davem@davemloft.net>
Subject: Re: D-cache aliasing issue in __block_prepare_write
From: David Miller <davem@davemloft.net>
In-Reply-To: <87ejtmn675.fsf@sw.ru>
References: <87ejtmn675.fsf@sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Monakhov Dmitriy <dmonakhov@openvz.org>
Date: Thu, 05 Oct 2006 19:16:46 +0400
Return-Path: <owner-linux-mm@kvack.org>
To: dmonakhov@openvz.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> It's seems I've found D-cache aliasing issue in fs/buffer.c
 ...
> x86 does not have cache aliasing problems, the problem could
> show up only on marginal archs, ia64 is the most frequently used.
> 
> Following is the patch against 2.6.18 fix this issue:

This patch looks good to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
