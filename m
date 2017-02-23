Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id B66176B0038
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 09:56:27 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id r18so793621wmd.1
        for <linux-mm@kvack.org>; Thu, 23 Feb 2017 06:56:27 -0800 (PST)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id d13si6366743wra.226.2017.02.23.06.56.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Feb 2017 06:56:26 -0800 (PST)
Received: by mail-wm0-x241.google.com with SMTP id v77so290164wmv.0
        for <linux-mm@kvack.org>; Thu, 23 Feb 2017 06:56:26 -0800 (PST)
Date: Thu, 23 Feb 2017 17:56:23 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] userfaultfd: hugetlbfs: add UFFDIO_COPY support for
 shared mappings
Message-ID: <20170223145623.GA855@node.shutemov.name>
References: <1487195210-12839-1-git-send-email-mike.kravetz@oracle.com>
 <20170216184100.GS25530@redhat.com>
 <20170221132545.GD13174@node.shutemov.name>
 <20170222151507.GI5037@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170222151507.GI5037@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Pavel Emelyanov <xemul@parallels.com>

On Wed, Feb 22, 2017 at 04:15:07PM +0100, Andrea Arcangeli wrote:
> On Tue, Feb 21, 2017 at 04:25:45PM +0300, Kirill A. Shutemov wrote:
> > I think more strict vma_is_anonymous() is a good thing.
> > 
> > But I don't see a point introducing one more helper. Let's just make the
> > existing helper work better.
> 
> That would be simpler agreed. The point of having an "unsafe" faster
> version was only for code running in page fault context where the
> additional check is unnecessary.

Well, I don't think that the cost of additional check is significant here.
And we can bring ->vm_ops a bit closer to ->vm_flags to avoid potential
cache miss.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
