Message-ID: <48D8ECB3.8070109@linux-foundation.org>
Date: Tue, 23 Sep 2008 08:18:43 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: [patch] mm: pageable memory allocator (for DRM-GEM?)
References: <20080923091017.GB29718@wotan.suse.de>	<48D8C326.80909@tungstengraphics.com> <20080923133137.c9e1f171.glisse@freedesktop.org>
In-Reply-To: <20080923133137.c9e1f171.glisse@freedesktop.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jerome Glisse <glisse@freedesktop.org>
Cc: =?ISO-8859-1?Q?Thomas_Hellstr=F6m?= <thomas@tungstengraphics.com>, Nick Piggin <npiggin@suse.de>, keith.packard@intel.com, eric@anholt.net, hugh@veritas.com, hch@infradead.org, airlied@linux.ie, jbarnes@virtuousgeek.org, dri-devel@lists.sourceforge.net, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Jerome Glisse wrote:
> 
> Also what about a uncached page allocator ? As some drivers might need
> them, there is no number but i think their was some concern that changing
> PAT too often might be costly and that we would better have a poll of
> such pages.

IA64 has an uncached allocator. See arch/ia64/include/asm/incached.h and
arch/ia64/kernel/uncached.c. Probably not exactly what you want but its a
starting point.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
