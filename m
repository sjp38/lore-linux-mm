Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id B40A16B0387
	for <linux-mm@kvack.org>; Wed, 22 Feb 2017 10:15:11 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id m57so3696455qtc.4
        for <linux-mm@kvack.org>; Wed, 22 Feb 2017 07:15:11 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o1si1097073qkd.15.2017.02.22.07.15.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Feb 2017 07:15:10 -0800 (PST)
Date: Wed, 22 Feb 2017 16:15:07 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] userfaultfd: hugetlbfs: add UFFDIO_COPY support for
 shared mappings
Message-ID: <20170222151507.GI5037@redhat.com>
References: <1487195210-12839-1-git-send-email-mike.kravetz@oracle.com>
 <20170216184100.GS25530@redhat.com>
 <20170221132545.GD13174@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170221132545.GD13174@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Pavel Emelyanov <xemul@parallels.com>

On Tue, Feb 21, 2017 at 04:25:45PM +0300, Kirill A. Shutemov wrote:
> I think more strict vma_is_anonymous() is a good thing.
> 
> But I don't see a point introducing one more helper. Let's just make the
> existing helper work better.

That would be simpler agreed. The point of having an "unsafe" faster
version was only for code running in page fault context where the
additional check is unnecessary.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
