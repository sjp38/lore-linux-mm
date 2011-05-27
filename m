Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A64D76B0012
	for <linux-mm@kvack.org>; Fri, 27 May 2011 18:12:38 -0400 (EDT)
Date: Fri, 27 May 2011 15:12:04 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: nommu: fix remap_pfn_range()
Message-Id: <20110527151204.4e60426e.akpm@linux-foundation.org>
In-Reply-To: <1306468203-8683-1-git-send-email-lliubbo@gmail.com>
References: <1306468203-8683-1-git-send-email-lliubbo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: gerg@snapgear.com, dhowells@redhat.com, lethal@linux-sh.org, geert@linux-m68k.org, vapier@gentoo.org, linux-mm@kvack.org

On Fri, 27 May 2011 11:50:03 +0800
Bob Liu <lliubbo@gmail.com> wrote:

> remap_pfn_range() does not update vma->end on no mmu arch which will
> cause munmap() fail because it can't match the vma.
> 
> eg. fb_mmap() in fbmem.c will call io_remap_pfn_range() which is
> remap_pfn_range() on nommu arch, if an address is not page aligned vma->start
> will be changed in remap_pfn_range(), but neither size nor vma->end will be
> updated. Then munmap(start, len) can't find the vma to free, because it need to
> compare (start + len) with vma->end.
> 

Also, I tagged the patch (or its successor) for -stable backporting as
the problem appears to be present in 2.6.38 (at least).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
