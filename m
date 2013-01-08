Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id C9E1E6B005A
	for <linux-mm@kvack.org>; Tue,  8 Jan 2013 11:30:30 -0500 (EST)
Date: Tue, 8 Jan 2013 18:31:41 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: oops in copy_page_rep()
Message-ID: <20130108163141.GA27555@shutemov.name>
References: <20130105152208.GA3386@redhat.com>
 <CAJd=RBCb0oheRnVCM4okVKFvKGzuLp9GpZJCkVY3RR-J=XEoBA@mail.gmail.com>
 <alpine.LNX.2.00.1301061037140.28950@eggly.anvils>
 <CAJd=RBAps4Qk9WLYbQhLkJd8d12NLV0CbjPYC6uqH_-L+Vu0VQ@mail.gmail.com>
 <CA+55aFyYAf6ztDLsxWFD+6jb++y0YNjso-9j+83Mm+3uQ=8PdA@mail.gmail.com>
 <CAJd=RBDTvCcYV8qAd-++_DOyDSypQD4Dvt216pG9nTQnWA2uCA@mail.gmail.com>
 <CA+55aFzfUABPycR82aNQhHNasQkL1kmxLN1rD0DJcByFtead3g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFzfUABPycR82aNQhHNasQkL1kmxLN1rD0DJcByFtead3g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>

On Tue, Jan 08, 2013 at 07:37:06AM -0800, Linus Torvalds wrote:
> On Tue, Jan 8, 2013 at 5:04 AM, Hillf Danton <dhillf@gmail.com> wrote:
> > On Tue, Jan 8, 2013 at 1:34 AM, Linus Torvalds
> > <torvalds@linux-foundation.org> wrote:
> >>
> >> Hmm. Is there some reason we never need to worry about it for the
> >> "pmd_numa()" case just above?
> >>
> >> A comment about this all might be a really good idea.
> >>
> > Yes Sir, added.
> 
> Heh. I was more thinking about why do_huge_pmd_wp_page() needs it, but
> do_huge_pmd_numa_page() does not.

It does. The check should be moved up.

> Also, do we actually need it for huge_pmd_set_accessed()? The
> *placement* of that thing confuses me. And because it confuses me, I'd
> like to understand it.

We need it for huge_pmd_set_accessed() too.

Looks like a mis-merge. The original patch for huge_pmd_set_accessed() was
correct: http://lkml.org/lkml/2012/10/25/402

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
