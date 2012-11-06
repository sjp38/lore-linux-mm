Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 639916B0044
	for <linux-mm@kvack.org>; Mon,  5 Nov 2012 20:25:06 -0500 (EST)
Date: Mon, 05 Nov 2012 20:25:01 -0500 (EST)
Message-Id: <20121105.202501.1246122770431623794.davem@davemloft.net>
Subject: Re: [PATCH 15/16] mm: use vm_unmapped_area() on sparc32
 architecture
From: David Miller <davem@davemloft.net>
In-Reply-To: <1352155633-8648-16-git-send-email-walken@google.com>
References: <1352155633-8648-1-git-send-email-walken@google.com>
	<1352155633-8648-16-git-send-email-walken@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: walken@google.com
Cc: akpm@linux-foundation.org, riel@redhat.com, hughd@google.com, linux-kernel@vger.kernel.org, linux@arm.linux.org.uk, ralf@linux-mips.org, lethal@linux-sh.org, cmetcalf@tilera.com, x86@kernel.org, wli@holomorphy.com, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-mips@linux-mips.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org

From: Michel Lespinasse <walken@google.com>
Date: Mon,  5 Nov 2012 14:47:12 -0800

> Update the sparc32 arch_get_unmapped_area function to make use of
> vm_unmapped_area() instead of implementing a brute force search.
> 
> Signed-off-by: Michel Lespinasse <walken@google.com>

Hmmm...

> -	if (flags & MAP_SHARED)
> -		addr = COLOUR_ALIGN(addr);
> -	else
> -		addr = PAGE_ALIGN(addr);

What part of vm_unmapped_area() is going to duplicate this special
aligning logic we need on sparc?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
