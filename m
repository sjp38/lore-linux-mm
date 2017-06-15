Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6A89E6B0292
	for <linux-mm@kvack.org>; Thu, 15 Jun 2017 17:24:43 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id w91so5056320wrb.13
        for <linux-mm@kvack.org>; Thu, 15 Jun 2017 14:24:43 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id k19si307007wrd.349.2017.06.15.14.24.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Jun 2017 14:24:42 -0700 (PDT)
Date: Thu, 15 Jun 2017 14:24:39 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v5] mm: huge-vmap: fail gracefully on unexpected huge
 vmap mappings
Message-Id: <20170615142439.7a431065465c5b4691aed1cc@linux-foundation.org>
In-Reply-To: <20170609082226.26152-1-ard.biesheuvel@linaro.org>
References: <20170609082226.26152-1-ard.biesheuvel@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: linux-mm@kvack.org, mhocko@suse.com, zhongjiang@huawei.com, labbott@fedoraproject.org, mark.rutland@arm.com, linux-arm-kernel@lists.infradead.org, dave.hansen@intel.com

On Fri,  9 Jun 2017 08:22:26 +0000 Ard Biesheuvel <ard.biesheuvel@linaro.org> wrote:

> Existing code that uses vmalloc_to_page() may assume that any
> address for which is_vmalloc_addr() returns true may be passed
> into vmalloc_to_page() to retrieve the associated struct page.
> 
> This is not un unreasonable assumption to make, but on architectures
> that have CONFIG_HAVE_ARCH_HUGE_VMAP=y, it no longer holds, and we
> need to ensure that vmalloc_to_page() does not go off into the weeds
> trying to dereference huge PUDs or PMDs as table entries.
> 
> Given that vmalloc() and vmap() themselves never create huge
> mappings or deal with compound pages at all, there is no correct
> answer in this case, so return NULL instead, and issue a warning.

Is this patch known to fix any current user-visible problem?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
