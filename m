Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 669586B0032
	for <linux-mm@kvack.org>; Wed, 21 Aug 2013 18:16:55 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id lf1so613645pab.24
        for <linux-mm@kvack.org>; Wed, 21 Aug 2013 15:16:54 -0700 (PDT)
Date: Wed, 21 Aug 2013 15:16:52 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: RE: [patch] mm, thp: count thp_fault_fallback anytime thp fault
 fails
In-Reply-To: <20130821142817.8EB4BE0090@blue.fi.intel.com>
Message-ID: <alpine.DEB.2.02.1308211516290.6225@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1308201716510.25665@chino.kir.corp.google.com> <20130821142817.8EB4BE0090@blue.fi.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 21 Aug 2013, Kirill A. Shutemov wrote:

> David Rientjes wrote:
> > Currently, thp_fault_fallback in vmstat only gets incremented if a
> > hugepage allocation fails.  If current's memcg hits its limit or the page
> > fault handler returns an error, it is incorrectly accounted as a
> > successful thp_fault_alloc.
> > 
> > Count thp_fault_fallback anytime the page fault handler falls back to
> > using regular pages and only count thp_fault_alloc when a hugepage has
> > actually been faulted.
> > 
> > Signed-off-by: David Rientjes <rientjes@google.com>
> 
> It's probably a good idea, but please make the behaviour consistent in
> do_huge_pmd_wp_page() and collapse path, otherwise it doesn't make sense.
> 

The collapse path has no fallback, the allocation either succeeds or it 
fails.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
