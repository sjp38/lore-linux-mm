Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j34NNNCt002313
	for <linux-mm@kvack.org>; Mon, 4 Apr 2005 19:23:23 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j34NNNGh198470
	for <linux-mm@kvack.org>; Mon, 4 Apr 2005 19:23:23 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11/8.12.11) with ESMTP id j34NNNPg010984
	for <linux-mm@kvack.org>; Mon, 4 Apr 2005 19:23:23 -0400
Date: Mon, 4 Apr 2005 16:22:54 -0700
From: Mike Kravetz <kravetz@us.ibm.com>
Subject: Re: [PATCH 1/4] create mm/Kconfig for arch-independent memory options
Message-ID: <20050404232254.GC6500@w-mikek2.ibm.com>
References: <E1DIViE-0006Kf-00@kernel.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <E1DIViE-0006Kf-00@kernel.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 04, 2005 at 10:50:09AM -0700, Dave Hansen wrote:
diff -puN mm/Kconfig~A6-mm-Kconfig mm/Kconfig
--- memhotplug/mm/Kconfig~A6-mm-Kconfig 2005-04-04 09:04:48.000000000 -0700
+++ memhotplug-dave/mm/Kconfig  2005-04-04 10:15:23.000000000 -0700
@@ -0,0 +1,25 @@
> +choice
> +	prompt "Memory model"
> +	default FLATMEM
> +	default SPARSEMEM if ARCH_SPARSEMEM_DEFAULT
> +	default DISCONTIGMEM if ARCH_DISCONTIGMEM_DEFAULT
> +

Yet the changes to the defconfig files that had DISCONTIGMEM as
the default look like.

-CONFIG_DISCONTIGMEM=y
+CONFIG_ARCH_DISCONTIGMEM_ENABLE=y

Do you need to set ARCH_DISCONTIGMEM_DEFAULT instead of just
CONFIG_ARCH_DISCONTIGMEM_ENABLE to have DISCONTIGMEM be the
default? or am I missing something?  I don't see
ARCH_DISCONTIGMEM_DEFAULT turned on by default in any of these
patches.

-- 
Mike
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
