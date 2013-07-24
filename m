Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id EB7C86B0036
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 14:52:43 -0400 (EDT)
Message-ID: <51F02273.1050308@parallels.com>
Date: Wed, 24 Jul 2013 22:52:35 +0400
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: Save soft-dirty bits on swapped pages
References: <20130724160826.GD24851@moon>
In-Reply-To: <20130724160826.GD24851@moon>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andy Lutomirski <luto@amacapital.net>, Matt Mackall <mpm@selenic.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Marcelo Tosatti <mtosatti@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Stephen Rothwell <sfr@canb.auug.org.au>

On 07/24/2013 08:08 PM, Cyrill Gorcunov wrote:
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
> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
> Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Matt Mackall <mpm@selenic.com>
> Cc: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
> Cc: Marcelo Tosatti <mtosatti@redhat.com>
> Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
> Cc: Stephen Rothwell <sfr@canb.auug.org.au>

Acked-by: Pavel Emelyanov <xemul@parallels.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
