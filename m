Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5F00A6B0038
	for <linux-mm@kvack.org>; Fri,  7 Oct 2016 14:16:34 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id tz10so33608888pab.3
        for <linux-mm@kvack.org>; Fri, 07 Oct 2016 11:16:34 -0700 (PDT)
Received: from mail-pf0-x236.google.com (mail-pf0-x236.google.com. [2607:f8b0:400e:c00::236])
        by mx.google.com with ESMTPS id yn6si17977037pab.271.2016.10.07.11.16.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Oct 2016 11:16:33 -0700 (PDT)
Received: by mail-pf0-x236.google.com with SMTP id i85so26833683pfa.3
        for <linux-mm@kvack.org>; Fri, 07 Oct 2016 11:16:33 -0700 (PDT)
Date: Fri, 7 Oct 2016 11:16:26 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: check VMA flags to avoid invalid PROT_NONE NUMA
 balancing
In-Reply-To: <20161007162240.GA14350@lucifer>
Message-ID: <alpine.LSU.2.11.1610071101410.7822@eggly.anvils>
References: <20160911225425.10388-1-lstoakes@gmail.com> <20160925184731.GA20480@lucifer> <CA+55aFwtHAT_ukyE=+s=3twW8v8QExLxpVcfEDyLihf+pn9qeA@mail.gmail.com> <1474842875.17726.38.camel@redhat.com> <CA+55aFyL+qFsJpxQufgRKgWeB6Yj0e1oapdu5mdU9_t+zwtBjg@mail.gmail.com>
 <20161007100720.GA14859@lucifer> <CA+55aFzOYk_1Jcr8CSKyqfkXaOApZvCkX0_27mZk7PvGSE4xSw@mail.gmail.com> <20161007162240.GA14350@lucifer>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lorenzo Stoakes <lstoakes@gmail.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>, tbsaunde@tbsaunde.org, robert@ocallahan.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Fri, 7 Oct 2016, Lorenzo Stoakes wrote:
> On Fri, Oct 07, 2016 at 08:34:15AM -0700, Linus Torvalds wrote:
> > Would you be willing to look at doing that kind of purely syntactic,
> > non-semantic cleanup first?
> 
> Sure, more than happy to do that! I'll work on a patch for this.
> 
> > I think that if we end up having the FOLL_FORCE semantics, we're
> > actually better off having an explicit FOLL_FORCE flag, and *not* do
> > some kind of implicit "under these magical circumstances we'll force
> > it anyway". The implicit thing is what we used to do long long ago, we
> > definitely don't want to.
> 
> That's a good point, it would definitely be considerably more 'magical', and
> expanding the conditions to include uprobes etc. would only add to that.
> 
> I wondered about an alternative parameter/flag but it felt like it was
> more-or-less FOLL_FORCE in a different form, at which point it may as well
> remain FOLL_FORCE :)

Adding Jan Kara (and Dave Hansen) to the Cc list: I think they were
pursuing get_user_pages() cleanups last year (which would remove the
force option from most callers anyway), and I've lost track of where
that all got to.  Lorenzo, please don't expend a lot of effort before
checking with Jan.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
