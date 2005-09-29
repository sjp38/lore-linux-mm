Message-ID: <433C4343.20205@tmr.com>
Date: Thu, 29 Sep 2005 15:40:51 -0400
From: Bill Davidsen <davidsen@tmr.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/7] CART - an advanced page replacement policy
References: <20050929180845.910895444@twins>
In-Reply-To: <20050929180845.910895444@twins>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Peter Zijlstra wrote:
> Multiple memory zone CART implementation for Linux.
> An advanced page replacement policy.
> 
> http://www.almaden.ibm.com/cs/people/dmodha/clockfast.pdf
> (IBM does hold patent rights to the base algorithm ARC)

Peter, this is a large patch, perhaps you could describe what configs 
benefit, how much, and what the right to use status of the patent might 
be. In other words, why would a reader of LKML put in this patch and try it?

The description of how it works is clear, but the problem solved isn't.

-- 
    -bill davidsen (davidsen@tmr.com)
"The secret to procrastination is to put things off until the
  last possible moment - but no longer"  -me

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
