Date: Thu, 26 Jul 2007 17:55:03 -0700 (PDT)
Message-Id: <20070726.175503.32096994.davem@davemloft.net>
Subject: Re: [PATCH/RFC] remove flush_tlb_pgtables
From: David Miller <davem@davemloft.net>
In-Reply-To: <1185497047.5495.159.camel@localhost.localdomain>
References: <1185497047.5495.159.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Fri, 27 Jul 2007 10:44:06 +1000
Return-Path: <owner-linux-mm@kvack.org>
To: benh@kernel.crashing.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> After my frv patch, nobody uses flush_tlb_pgtables anymore, this patch
> removes all remaining traces of it from all archs.
> 
> Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>

Acked-by: David S. Miller <davem@davemloft.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
