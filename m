Date: Sat, 8 Mar 2008 00:28:51 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [6/13] Core maskable allocator
Message-ID: <20080307232851.GA19757@one.firstfloor.org>
References: <200803071007.493903088@firstfloor.org> <20080307090716.9D3E91B419C@basil.firstfloor.org> <20080307211322.GD7589@cvg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080307211322.GD7589@cvg>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Andi, I'm a little confused by _this_ statistics. We could get p = NULL
> there and change MASK_HIGH_WASTE even have mask not allocated. Am I
> wrong or miss something? Or maybe there should be '&&' instead of '||'?

You're right the statistics counter is increased incorrectly for the 
p == NULL case. I'll fix that thanks. || is correct, see the comment
above.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
