Date: Fri, 17 Dec 2004 18:13:21 +0100
From: Andi Kleen <ak@suse.de>
Subject: Re: [patch] kill off ARCH_HAS_ATOMIC_UNSIGNED
Message-ID: <20041217171321.GH14229@wotan.suse.de>
References: <E1CfLbi-0005Tu-00@kernel.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <E1CfLbi-0005Tu-00@kernel.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm@kvack.org, ak@suse.de
List-ID: <linux-mm.kvack.org>

> -#ifdef ARCH_HAS_ATOMIC_UNSIGNED
> -typedef unsigned page_flags_t;
> -#else
>  typedef unsigned long page_flags_t;
> -#endif

Better remove the type completely and use unsigned long in struct page. 
No need for typedefs when not needed.

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
