Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id AA07B6B0038
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 15:51:28 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id g49so44914588qta.0
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 12:51:28 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x194si7871274qkx.310.2017.02.17.12.51.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Feb 2017 12:51:28 -0800 (PST)
Date: Fri, 17 Feb 2017 21:51:24 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] userfaultfd: hugetlbfs: add UFFDIO_COPY support for
 shared mappings
Message-ID: <20170217205124.GV25530@redhat.com>
References: <1487195210-12839-1-git-send-email-mike.kravetz@oracle.com>
 <20170216184100.GS25530@redhat.com>
 <c9c8cafe-baa7-05b4-34ea-1dfa5523a85f@oracle.com>
 <20170217155241.GT25530@redhat.com>
 <20170217121738.f5b2e24474021f38fdb72845@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170217121738.f5b2e24474021f38fdb72845@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Pavel Emelyanov <xemul@parallels.com>, "Kirill A. Shutemov" <kirill@shutemov.name>

On Fri, Feb 17, 2017 at 12:17:38PM -0800, Andrew Morton wrote:
> I merged this up and a small issue remains:

Great!

> The value of `err' here is EINVAL.  That sems appropriate, but it only
> happens by sheer luck.

It might have been programmer luck but just for completeness, at
runtime no luck was needed (the temporary setting to ENOENT is undoed
before the if clause is closed). Your addition is surely safer just in
case of future changes missing how we inherited the EINVAL in both
branches, thanks! (plus the compiler should be able to optimize it
away until after it will be needed)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
