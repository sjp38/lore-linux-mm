Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id BC65B6B005A
	for <linux-mm@kvack.org>; Tue,  8 Jan 2013 13:01:51 -0500 (EST)
Date: Tue, 8 Jan 2013 20:03:02 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: oops in copy_page_rep()
Message-ID: <20130108180302.GA27871@shutemov.name>
References: <CAJd=RBCb0oheRnVCM4okVKFvKGzuLp9GpZJCkVY3RR-J=XEoBA@mail.gmail.com>
 <alpine.LNX.2.00.1301061037140.28950@eggly.anvils>
 <CAJd=RBAps4Qk9WLYbQhLkJd8d12NLV0CbjPYC6uqH_-L+Vu0VQ@mail.gmail.com>
 <CA+55aFyYAf6ztDLsxWFD+6jb++y0YNjso-9j+83Mm+3uQ=8PdA@mail.gmail.com>
 <CAJd=RBDTvCcYV8qAd-++_DOyDSypQD4Dvt216pG9nTQnWA2uCA@mail.gmail.com>
 <CA+55aFzfUABPycR82aNQhHNasQkL1kmxLN1rD0DJcByFtead3g@mail.gmail.com>
 <20130108163141.GA27555@shutemov.name>
 <CA+55aFzaTvF7nYxWBT-G_b=xGz+_akRAeJ=U9iHy+Y=ZPo=pbA@mail.gmail.com>
 <20130108173058.GA27727@shutemov.name>
 <20130108174951.GG9163@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130108174951.GG9163@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>

On Tue, Jan 08, 2013 at 06:49:51PM +0100, Andrea Arcangeli wrote:
> Hi Kirill,
> 
> On Tue, Jan 08, 2013 at 07:30:58PM +0200, Kirill A. Shutemov wrote:
> > Merged patch is obviously broken: huge_pmd_set_accessed() can be called
> > only if the pmd is under splitting.
> 
> Of course I assume you meant "only if the pmd is not under splitting".

The broken merged patch has this:

+                       if (dirty && !pmd_write(orig_pmd) &&
                            !pmd_trans_splitting(orig_pmd)) {
			[...]
+                       } else {
+                               huge_pmd_set_accessed(mm, vma, address, pmd,
+                                                     orig_pmd, dirty);
                        }

> But no, setting a bitflag like the young bit or clearing or setting
> the numa bit won't screw with split_huge_page and it's safe even if
> the pmd is under splitting.

Okay. Thanks for clarification for me.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
