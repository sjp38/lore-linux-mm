Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 6A1606B002B
	for <linux-mm@kvack.org>; Wed, 17 Oct 2012 11:54:11 -0400 (EDT)
Date: Wed, 17 Oct 2012 16:54:02 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v2] mm: thp: Set the accessed flag for old pages on
 access fault.
Message-ID: <20121017155401.GJ5973@mudshark.cambridge.arm.com>
References: <1349197151-19645-1-git-send-email-will.deacon@arm.com>
 <20121002150104.da57fa94.akpm@linux-foundation.org>
 <20121017130125.GH5973@mudshark.cambridge.arm.com>
 <20121017.112620.1865348978594874782.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121017.112620.1865348978594874782.davem@davemloft.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "mhocko@suse.cz" <mhocko@suse.cz>, "kirill@shutemov.name" <kirill@shutemov.name>, "aarcange@redhat.com" <aarcange@redhat.com>, "cmetcalf@tilera.com" <cmetcalf@tilera.com>, Steve Capper <Steve.Capper@arm.com>

On Wed, Oct 17, 2012 at 04:26:20PM +0100, David Miller wrote:
> From: Will Deacon <will.deacon@arm.com>
> Date: Wed, 17 Oct 2012 14:01:25 +0100
> 
> > +		update_mmu_cache(vma, address, pmd);
> 
> This won't build, use update_mmu_cache_pmd().

Good catch. They're both empty macros on ARM, so the typechecker didn't spot
it. Updated patch below.

Cheers,

Will

--->8
