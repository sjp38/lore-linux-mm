Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 4005D6B002B
	for <linux-mm@kvack.org>; Wed, 17 Oct 2012 11:26:23 -0400 (EDT)
Date: Wed, 17 Oct 2012 11:26:20 -0400 (EDT)
Message-Id: <20121017.112620.1865348978594874782.davem@davemloft.net>
Subject: Re: [PATCH v2] mm: thp: Set the accessed flag for old pages on
 access fault.
From: David Miller <davem@davemloft.net>
In-Reply-To: <20121017130125.GH5973@mudshark.cambridge.arm.com>
References: <1349197151-19645-1-git-send-email-will.deacon@arm.com>
	<20121002150104.da57fa94.akpm@linux-foundation.org>
	<20121017130125.GH5973@mudshark.cambridge.arm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: will.deacon@arm.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, mhocko@suse.cz, kirill@shutemov.name, aarcange@redhat.com, cmetcalf@tilera.com, Steve.Capper@arm.com

From: Will Deacon <will.deacon@arm.com>
Date: Wed, 17 Oct 2012 14:01:25 +0100

> +		update_mmu_cache(vma, address, pmd);

This won't build, use update_mmu_cache_pmd().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
