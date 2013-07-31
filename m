Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id DB62E6B0031
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 04:16:37 -0400 (EDT)
Message-ID: <51F8C7CC.6010703@parallels.com>
Date: Wed, 31 Jul 2013 12:16:12 +0400
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: Re: [patch 1/2] [PATCH] mm: Save soft-dirty bits on swapped pages
References: <20130730204154.407090410@gmail.com> <20130730204654.844299768@gmail.com>
In-Reply-To: <20130730204654.844299768@gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, luto@amacapital.net, gorcunov@openvz.org, mpm@selenic.com, xiaoguangrong@linux.vnet.ibm.com, mtosatti@redhat.com, kosaki.motohiro@gmail.com, sfr@canb.auug.org.au, peterz@infradead.org, aneesh.kumar@linux.vnet.ibm.com

On 07/31/2013 12:41 AM, Cyrill Gorcunov wrote:

> Andy Lutomirski reported that in case if a page with _PAGE_SOFT_DIRTY
> bit set get swapped out, the bit is getting lost and no longer
> available when pte read back.
> 
> To resolve this we introduce _PTE_SWP_SOFT_DIRTY bit which is
> saved in pte entry for the page being swapped out. When such page
> is to be read back from a swap cache we check for bit presence
> and if it's there we clear it and restore the former _PAGE_SOFT_DIRTY
> bit back.
> 
> One of the problem was to find a place in pte entry where we can
> save the _PTE_SWP_SOFT_DIRTY bit while page is in swap. The
> _PAGE_PSE was chosen for that, it doesn't intersect with swap
> entry format stored in pte.
> 
> Reported-by: Andy Lutomirski <luto@amacapital.net>
> Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>

Acked-by: Pavel Emelyanov <xemul@parallels.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
