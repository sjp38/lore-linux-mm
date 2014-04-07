From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: mm: BUG in do_huge_pmd_wp_page
Date: Mon, 7 Apr 2014 23:11:06 +0300
Message-ID: <20140407201106.GA21633@node.dhcp.inet.fi>
References: <51559150.3040407@oracle.com>
 <515D882E.6040001@oracle.com>
 <533F09F0.1050206@oracle.com>
 <20140407144835.GA17774@node.dhcp.inet.fi>
 <5342FF3E.6030306@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5342FF3E.6030306@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Mel Gorman <mgorman@suse.de>, Dave Jones <davej@redhat.com>, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

On Mon, Apr 07, 2014 at 03:40:46PM -0400, Sasha Levin wrote:
> It also breaks fairly quickly under testing because:
> 
> On 04/07/2014 10:48 AM, Kirill A. Shutemov wrote:
> > +	if (IS_ENABLED(CONFIG_DEBUG_PAGEALLOC)) {
> > +		spin_lock(ptl);
> 
> ^ We go into atomic
> 
> > +		if (unlikely(!pmd_same(*pmd, orig_pmd)))
> > +			goto out_race;
> > +	}
> > +
> >  	if (!page)
> >  		clear_huge_page(new_page, haddr, HPAGE_PMD_NR);
> >  	else
> >  		copy_user_huge_page(new_page, page, haddr, vma, HPAGE_PMD_NR);
> 
> copy_user_huge_page() doesn't like running in atomic state,
> and asserts might_sleep().

Okay, I'll try something else.

-- 
 Kirill A. Shutemov
