Date: Thu, 27 Dec 2007 16:16:02 -0800 (PST)
Message-Id: <20071227.161602.117475287.davem@davemloft.net>
Subject: Re: [PATCH 02/10] percpu: Move arch XX_PER_CPU_XX definitions into
 linux/percpu.h
From: David Miller <davem@davemloft.net>
In-Reply-To: <20071228001047.159448000@sgi.com>
References: <20071228001046.854702000@sgi.com>
	<20071228001047.159448000@sgi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: travis@sgi.com
Date: Thu, 27 Dec 2007 16:10:48 -0800
Return-Path: <owner-linux-mm@kvack.org>
To: travis@sgi.com
Cc: akpm@linux-foundation.org, clameter@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rusty@rustcorp.com.au, ak@suse.de
List-ID: <linux-mm.kvack.org>

> V1->V2:
> - Special consideration for IA64: Add the ability to specify
>   arch specific per cpu flags
> 
> The arch definitions are all the same. So move them into linux/percpu.h.
> 
> We cannot move DECLARE_PER_CPU since some include files just include
> asm/percpu.h to avoid include recursion problems.
> 
> Cc: Rusty Russell <rusty@rustcorp.com.au>
> Cc: Andi Kleen <ak@suse.de>
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> Signed-off-by: Mike Travis <travis@sgi.com>

Acked-by: David S. Miller <davem@davemloft.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
