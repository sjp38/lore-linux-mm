Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id BD4B76B0032
	for <linux-mm@kvack.org>; Wed, 24 Apr 2013 18:51:22 -0400 (EDT)
Message-ID: <517861E0.7030801@zytor.com>
Date: Wed, 24 Apr 2013 15:51:12 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: mm: BUG in do_huge_pmd_wp_page
References: <51559150.3040407@oracle.com> <20130410080202.GB21292@blaptop>
In-Reply-To: <20130410080202.GB21292@blaptop>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Dave Jones <davej@redhat.com>, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On 04/10/2013 01:02 AM, Minchan Kim wrote:
> 
> When I am looking at the code, I was wonder about the logic of GHZP(aka,
> get_huge_zero_page) reference handling. The logic depends on that page
> allocator never alocate PFN 0.
> 
> Who makes sure it? What happens if allocator allocates PFN 0?
> I don't know all of architecture makes sure it.
> You investigated it for all arches?
> 

This isn't manifest, right?  At least on x86 we should never, ever
allocate PFN 0.

	-hpa


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
