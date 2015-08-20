Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 4830C6B0253
	for <linux-mm@kvack.org>; Thu, 20 Aug 2015 19:38:38 -0400 (EDT)
Received: by padfo6 with SMTP id fo6so32620054pad.0
        for <linux-mm@kvack.org>; Thu, 20 Aug 2015 16:38:38 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id pa5si9810664pac.22.2015.08.20.16.38.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Aug 2015 16:38:37 -0700 (PDT)
Date: Thu, 20 Aug 2015 16:38:36 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCHv3 0/5] Fix compound_head() race
Message-Id: <20150820163836.b3b69f2bf36dba7020bdc893@linux-foundation.org>
In-Reply-To: <20150820123107.GA31768@node.dhcp.inet.fi>
References: <1439976106-137226-1-git-send-email-kirill.shutemov@linux.intel.com>
	<20150820123107.GA31768@node.dhcp.inet.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 20 Aug 2015 15:31:07 +0300 "Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> On Wed, Aug 19, 2015 at 12:21:41PM +0300, Kirill A. Shutemov wrote:
> > Here's my attempt on fixing recently discovered race in compound_head().
> > It should make compound_head() reliable in all contexts.
> > 
> > The patchset is against Linus' tree. Let me know if it need to be rebased
> > onto different baseline.
> > 
> > It's expected to have conflicts with my page-flags patchset and probably
> > should be applied before it.
> > 
> > v3:
> >    - Fix build without hugetlb;
> >    - Drop page->first_page;
> >    - Update comment for free_compound_page();
> >    - Use 'unsigned int' for page order;
> > 
> > v2: Per Hugh's suggestion page->compound_head is moved into third double
> >     word. This way we can avoid memory overhead which v1 had in some
> >     cases.
> > 
> >     This place in struct page is rather overloaded. More testing is
> >     required to make sure we don't collide with anyone.
> 
> Andrew, can we have the patchset applied, if nobody has objections?

I've been hoping to hear from Hugh and I wasn't planning on processing
these before the 4.2 release.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
