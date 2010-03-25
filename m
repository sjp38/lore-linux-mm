Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id CD6D06B0071
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 01:28:22 -0400 (EDT)
Date: Thu, 25 Mar 2010 16:28:14 +1100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH 1/2] mm/vmalloc: Export purge_vmap_area_lazy()
Message-ID: <20100325052814.GA7493@laptop.nomadix.com>
References: <1269417391.8599.188.camel@pasglop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1269417391.8599.188.camel@pasglop>
Sender: owner-linux-mm@kvack.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Nathan Fontenot <nfont@austin.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed, Mar 24, 2010 at 06:56:31PM +1100, Benjamin Herrenschmidt wrote:
> Some powerpc code needs to ensure that all previous iounmap/vunmap has
> really been flushed out of the MMU hash table. Without that, various
> hotplug operations may fail when trying to return those pieces to
> the hypervisor due to existing active mappings.
> 
> This exports purge_vmap_area_lazy() to allow the powerpc code to perform
> that purge when unplugging devices.

You want vm_unmap_aliases(), which also flushes entries in the
per-cpu vmap allocator (and is already exported for other code
that has similar problems).

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
