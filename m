Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2D6566B0071
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 04:28:19 -0400 (EDT)
Subject: Re: [PATCH 1/2] mm/vmalloc: Export purge_vmap_area_lazy()
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20100325052814.GA7493@laptop.nomadix.com>
References: <1269417391.8599.188.camel@pasglop>
	 <20100325052814.GA7493@laptop.nomadix.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 25 Mar 2010 19:25:59 +1100
Message-ID: <1269505559.8599.239.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Nathan Fontenot <nfont@austin.ibm.com>
List-ID: <linux-mm.kvack.org>


> You want vm_unmap_aliases(), which also flushes entries in the
> per-cpu vmap allocator (and is already exported for other code
> that has similar problems).

Ok, I missed that one. I'll update my patch. Thanks.

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
