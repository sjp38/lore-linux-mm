Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 9A2909003C7
	for <linux-mm@kvack.org>; Wed, 22 Jul 2015 19:49:26 -0400 (EDT)
Received: by pdrg1 with SMTP id g1so146276409pdr.2
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 16:49:26 -0700 (PDT)
Received: from mail-pd0-x22e.google.com (mail-pd0-x22e.google.com. [2607:f8b0:400e:c02::22e])
        by mx.google.com with ESMTPS id yq9si7113176pab.223.2015.07.22.16.49.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jul 2015 16:49:25 -0700 (PDT)
Received: by pdbnt7 with SMTP id nt7so75339282pdb.0
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 16:49:25 -0700 (PDT)
Date: Wed, 22 Jul 2015 16:49:23 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mmap.2: document the munmap exception for underlying
 page size
In-Reply-To: <55B027D3.4020608@oracle.com>
Message-ID: <alpine.DEB.2.10.1507221646100.14953@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1507211736300.24133@chino.kir.corp.google.com> <55B027D3.4020608@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: mtk.manpages@gmail.com, Hugh Dickins <hughd@google.com>, Davide Libenzi <davidel@xmailserver.org>, Eric B Munson <emunson@akamai.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-man@vger.kernel.org

On Wed, 22 Jul 2015, Mike Kravetz wrote:

> On 07/21/2015 05:41 PM, David Rientjes wrote:
> > munmap(2) will fail with an errno of EINVAL for hugetlb memory if the
> > length is not a multiple of the underlying page size.
> > 
> > Documentation/vm/hugetlbpage.txt was updated to specify this behavior
> > since Linux 4.1 in commit 80d6b94bd69a ("mm, doc: cleanup and clarify
> > munmap behavior for hugetlb memory").
> > 
> > Signed-off-by: David Rientjes <rientjes@google.com>
> > ---
> >   man2/mmap.2 | 4 ++++
> >   1 file changed, 4 insertions(+)
> > 
> > diff --git a/man2/mmap.2 b/man2/mmap.2
> > --- a/man2/mmap.2
> > +++ b/man2/mmap.2
> > @@ -383,6 +383,10 @@ All pages containing a part
> >   of the indicated range are unmapped, and subsequent references
> >   to these pages will generate
> >   .BR SIGSEGV .
> > +An exception is when the underlying memory is not of the native page
> > +size, such as hugetlb page sizes, whereas
> > +.I length
> > +must be a multiple of the underlying page size.
> >   It is not an error if the
> >   indicated range does not contain any mapped pages.
> >   .SS Timestamps changes for file-backed mappings
> > 
> > --
> 
> Should we also add a similar comment for the mmap offset?  Currently
> the man page says:
> 
> "offset must be a multiple of the page size as returned by
>  sysconf(_SC_PAGE_SIZE)."
> 
> For hugetlbfs, I beieve the offset must be a multiple of the
> hugetlb page size.  A similar comment/exception about using
> the "underlying page size" would apply here as well.
> 

Yes, that makes sense, thanks.  We should also explicitly say that mmap(2) 
automatically aligns length to be hugepage aligned if backed by hugetlbfs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
