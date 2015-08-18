Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 26B2D6B0253
	for <linux-mm@kvack.org>; Tue, 18 Aug 2015 14:23:03 -0400 (EDT)
Received: by wijp15 with SMTP id p15so107511277wij.0
        for <linux-mm@kvack.org>; Tue, 18 Aug 2015 11:23:02 -0700 (PDT)
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com. [209.85.212.172])
        by mx.google.com with ESMTPS id d13si34946256wjs.119.2015.08.18.11.23.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Aug 2015 11:23:01 -0700 (PDT)
Received: by wijp15 with SMTP id p15so107510757wij.0
        for <linux-mm@kvack.org>; Tue, 18 Aug 2015 11:23:00 -0700 (PDT)
Date: Tue, 18 Aug 2015 21:22:59 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv2 3/4] mm: pack compound_dtor and compound_order into one
 word in struct page
Message-ID: <20150818182259.GB21383@node.dhcp.inet.fi>
References: <1439824145-25397-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1439824145-25397-4-git-send-email-kirill.shutemov@linux.intel.com>
 <20150818160530.GM5033@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150818160530.GM5033@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Aug 18, 2015 at 06:05:31PM +0200, Michal Hocko wrote:
> On Mon 17-08-15 18:09:04, Kirill A. Shutemov wrote:
> [...]
> > +/* Keep the enum in sync with compound_page_dtors array in mm/page_alloc.c */
> > +enum {
> > +	NULL_COMPOUND_DTOR,
> > +	COMPOUND_PAGE_DTOR,
> > +	HUGETLB_PAGE_DTOR,
> > +	NR_COMPOUND_DTORS,
> > +};
> [...]
> > +static void free_compound_page(struct page *page);
> > +compound_page_dtor * const compound_page_dtors[] = {
> > +	NULL,
> > +	free_compound_page,
> > +	free_huge_page,
> > +};
> > +
> 
> Both need ifdef CONFIG_HUGETLB_PAGE as my compile test batter just found
> out.

I'll fix that.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
