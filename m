Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 41DB46B0032
	for <linux-mm@kvack.org>; Thu, 16 May 2013 09:52:50 -0400 (EDT)
Date: Thu, 16 May 2013 14:52:34 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [RFC PATCH v2 06/11] ARM64: mm: Restore memblock limit when
 map_mem finished.
Message-ID: <20130516135233.GB18308@arm.com>
References: <1368006763-30774-1-git-send-email-steve.capper@linaro.org>
 <1368006763-30774-7-git-send-email-steve.capper@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1368006763-30774-7-git-send-email-steve.capper@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steve Capper <steve.capper@linaro.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Michal Hocko <mhocko@suse.cz>, Ken Chen <kenchen@google.com>, Mel Gorman <mgorman@suse.de>, Will Deacon <Will.Deacon@arm.com>, "patches@linaro.org" <patches@linaro.org>

On Wed, May 08, 2013 at 10:52:38AM +0100, Steve Capper wrote:
> In paging_init the memblock limit is set to restrict any addresses
> returned by early_alloc to fit within the initial direct kernel
> mapping in swapper_pg_dir. This allows map_mem to allocate puds,
> pmds and ptes from the initial direct kernel mapping.
> 
> The limit stays low after paging_init() though, meaning any
> bootmem allocations will be from a restricted subset of memory.
> Gigabyte huge pages, for instance, are normally allocated from
> bootmem as their order (18) is too large for the default buddy
> allocator (MAX_ORDER = 11).
> 
> This patch restores the memblock limit when map_mem has finished,
> allowing gigabyte huge pages (and other objects) to be allocated
> from all of bootmem.
> 
> Signed-off-by: Steve Capper <steve.capper@linaro.org>

Acked-by: Catalin Marinas <catalin.marinas@arm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
