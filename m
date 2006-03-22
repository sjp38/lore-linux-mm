Received: by uproxy.gmail.com with SMTP id h2so36025ugf
        for <linux-mm@kvack.org>; Wed, 22 Mar 2006 00:59:33 -0800 (PST)
Message-ID: <bc56f2f0603220059x6b2a30b8h@mail.gmail.com>
Date: Wed, 22 Mar 2006 03:59:33 -0500
From: "Stone Wang" <pwstone@gmail.com>
Subject: Re: PATCH][1/8] 2.6.15 mlock: make_pages_wired/unwired
In-Reply-To: <44209A26.3040102@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <bc56f2f0603200536scb87a8ck@mail.gmail.com>
	 <441FEFB4.6050700@yahoo.com.au>
	 <bc56f2f0603210803l28145c7dj@mail.gmail.com>
	 <44209A26.3040102@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

2006/3/21, Nick Piggin <nickpiggin@yahoo.com.au>:
> Stone Wang wrote:
> > We dont account HugeTLB pages for:
> >
> > 1. HugeTLB pages themselves are not reclaimable.
> >
> > 2. If we count HugeTLB pages in "Wired",then we would have no mind
> >    how many of the "Wired" are HugeTLB pages, and how many are
> > normal-size pages.
> >    Thus, hard to get a clear map of physical memory use,for example:
> >      how many pages are reclaimable?
> >    If we must count HugeTLB pages,more fields should be added to
> > "/proc/meminfo",
> >    for exmaple: "Wired HugeTLB:", "Wired Normal:".
> >
>
> Then why do you wire them at all? Your unwire function does not appear
> to be able to unwire them.

We didnt wire them.

Check get_user_pages():

        /* We dont account wired HugeTLB pages */
        if (is_vm_hugetlb_page(vma)) {
            i = follow_hugetlb_page(mm, vma, pages, vmas,
                        &start, &len, i);
            continue;
        }


Shaoping Wang

>
> --
> SUSE Labs, Novell Inc.
> Send instant messages to your online friends http://au.messenger.yahoo.com
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
