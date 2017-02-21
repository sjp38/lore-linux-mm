Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id CFF246B03A5
	for <linux-mm@kvack.org>; Tue, 21 Feb 2017 08:25:52 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id q124so15969063wmg.2
        for <linux-mm@kvack.org>; Tue, 21 Feb 2017 05:25:52 -0800 (PST)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id j206si16472334wmj.86.2017.02.21.05.25.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Feb 2017 05:25:51 -0800 (PST)
Received: by mail-wm0-x242.google.com with SMTP id v77so19721913wmv.0
        for <linux-mm@kvack.org>; Tue, 21 Feb 2017 05:25:51 -0800 (PST)
Date: Tue, 21 Feb 2017 16:25:45 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] userfaultfd: hugetlbfs: add UFFDIO_COPY support for
 shared mappings
Message-ID: <20170221132545.GD13174@node.shutemov.name>
References: <1487195210-12839-1-git-send-email-mike.kravetz@oracle.com>
 <20170216184100.GS25530@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170216184100.GS25530@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Pavel Emelyanov <xemul@parallels.com>

On Thu, Feb 16, 2017 at 07:41:00PM +0100, Andrea Arcangeli wrote:
> Kirill what's your take on making the registration checks stricter?
> If we would add a vma_is_anonymous_not_in_fault implemented like above
> vma_can_userfault would just need a
> s/vma_is_anonymous/vma_is_anonymous_not_in_fault/ and it would be more
> strict. khugepaged could be then converted to use it too instead of
> hardcoding this vm_flags check. Unless I'm mistaken I would consider
> such a change to the registration code, purely a cleanup to add a more
> strict check.

[sorry for later response]

I think more strict vma_is_anonymous() is a good thing.

But I don't see a point introducing one more helper. Let's just make the
existing helper work better.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
