Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id C9B2C6B0002
	for <linux-mm@kvack.org>; Thu, 25 Apr 2013 21:30:32 -0400 (EDT)
Date: Fri, 26 Apr 2013 10:30:30 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: mm: BUG in do_huge_pmd_wp_page
Message-ID: <20130426013030.GA26691@blaptop>
References: <51559150.3040407@oracle.com>
 <20130410080202.GB21292@blaptop>
 <517861E0.7030801@zytor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <517861E0.7030801@zytor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Dave Jones <davej@redhat.com>, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Hello hpa,

On Wed, Apr 24, 2013 at 03:51:12PM -0700, H. Peter Anvin wrote:
> On 04/10/2013 01:02 AM, Minchan Kim wrote:
> > 
> > When I am looking at the code, I was wonder about the logic of GHZP(aka,
> > get_huge_zero_page) reference handling. The logic depends on that page
> > allocator never alocate PFN 0.
> > 
> > Who makes sure it? What happens if allocator allocates PFN 0?
> > I don't know all of architecture makes sure it.
> > You investigated it for all arches?
> > 
> 
> This isn't manifest, right?  At least on x86 we should never, ever
> allocate PFN 0.

Thanks for the confirm.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
