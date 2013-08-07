Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id EF0D76B0032
	for <linux-mm@kvack.org>; Wed,  7 Aug 2013 16:31:06 -0400 (EDT)
Received: by mail-la0-f49.google.com with SMTP id ev20so1528687lab.8
        for <linux-mm@kvack.org>; Wed, 07 Aug 2013 13:31:05 -0700 (PDT)
Date: Thu, 8 Aug 2013 00:31:03 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [patch 2/2] [PATCH] mm: Save soft-dirty bits on file pages
Message-ID: <20130807203103.GP7999@moon>
References: <20130730204154.407090410@gmail.com>
 <20130730204654.966378702@gmail.com>
 <20130807132812.60ad4bfe85127794094d385e@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130807132812.60ad4bfe85127794094d385e@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, luto@amacapital.net, xemul@parallels.com, mpm@selenic.com, xiaoguangrong@linux.vnet.ibm.com, mtosatti@redhat.com, kosaki.motohiro@gmail.com, sfr@canb.auug.org.au, peterz@infradead.org, aneesh.kumar@linux.vnet.ibm.com

On Wed, Aug 07, 2013 at 01:28:12PM -0700, Andrew Morton wrote:
> 
> Good god.
> 
> I wonder if these can be turned into out-of-line functions in some form
> which humans can understand.
> 
> or
> 
> #define pte_to_pgoff(pte)
> 	frob(pte, PTE_FILE_SHIFT1, PTE_FILE_BITS1) +
> 	frob(PTE_FILE_SHIFT2, PTE_FILE_BITS2) +
> 	frob(PTE_FILE_SHIFT3, PTE_FILE_BITS3) +
> 	frob(PTE_FILE_SHIFT4, PTE_FILE_BITS1 + PTE_FILE_BITS2 + PTE_FILE_BITS3)

I copied this code from existing one, not mine invention ;)
I'll clean it up on top.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
