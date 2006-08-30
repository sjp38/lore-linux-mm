Date: Wed, 30 Aug 2006 15:27:05 -0700 (PDT)
Message-Id: <20060830.152705.27955313.davem@davemloft.net>
Subject: Re: [RFC][PATCH 5/9] sparc64 generic PAGE_SIZE
From: David Miller <davem@davemloft.net>
In-Reply-To: <20060830221608.A33491C8@localhost.localdomain>
References: <20060830221604.E7320C0F@localhost.localdomain>
	<20060830221608.A33491C8@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Dave Hansen <haveblue@us.ibm.com>
Date: Wed, 30 Aug 2006 15:16:08 -0700
Return-Path: <owner-linux-mm@kvack.org>
To: haveblue@us.ibm.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> 
> This is the sparc64 portion to convert it over to the generic PAGE_SIZE
> framework.
> 
> * Change all references to CONFIG_SPARC64_PAGE_SIZE_*KB to
>   CONFIG_PAGE_SIZE_* and update the defconfig.
> * remove sparc64-specific Kconfig menu
> * add sparc64 default of 8k pages to mm/Kconfig
> * remove generic support for 4k pages
> * add support for 8k, 64k, 512k, and 4MB pages
> 
> Signed-off-by: Dave Hansen <haveblue@us.ibm.com>

Signed-off-by: David S. Miller <davem@davemloft.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
