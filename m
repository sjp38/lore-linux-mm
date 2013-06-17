Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 1A5776B0032
	for <linux-mm@kvack.org>; Mon, 17 Jun 2013 18:33:24 -0400 (EDT)
Date: Mon, 17 Jun 2013 15:33:22 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] thp: define HPAGE_PMD_* constans as BUILD_BUG() if !THP
Message-Id: <20130617153322.f3cecaa54aacd465fedb7c36@linux-foundation.org>
In-Reply-To: <20130617222703.D8C4AE0090@blue.fi.intel.com>
References: <1371506740-14606-1-git-send-email-kirill.shutemov@linux.intel.com>
	<20130617151417.f7610d56b4b43ced30c40133@linux-foundation.org>
	<20130617222703.D8C4AE0090@blue.fi.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 18 Jun 2013 01:27:03 +0300 (EEST) "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:

> > >  #else /* CONFIG_TRANSPARENT_HUGEPAGE */
> > > +#define HPAGE_PMD_SHIFT ({ BUILD_BUG(); 0; })
> > > +#define HPAGE_PMD_MASK ({ BUILD_BUG(); 0; })
> > > +#define HPAGE_PMD_SIZE ({ BUILD_BUG(); 0; })
> > >  
> > 
> > We've done this sort of thing before and it blew up.  We do want to be
> > able to use things like HPAGE_PMD_foo in global-var initialisers and
> > definitions, but the problem is that BUILD_BUG() can't be used outside
> > functions.
> 
> I don't see how it's a blocker. For global variables, we will have to use
> #ifdefs, but the approach is still useful for in-function code.

OK.  Current mainline uses BUILD_BUG() here, so I guess the change
won't break anything.  Yet.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
