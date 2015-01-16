Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f174.google.com (mail-qc0-f174.google.com [209.85.216.174])
	by kanga.kvack.org (Postfix) with ESMTP id ADFFD6B0032
	for <linux-mm@kvack.org>; Fri, 16 Jan 2015 08:12:41 -0500 (EST)
Received: by mail-qc0-f174.google.com with SMTP id c9so16813796qcz.5
        for <linux-mm@kvack.org>; Fri, 16 Jan 2015 05:12:41 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u47si5967547qge.5.2015.01.16.05.12.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Jan 2015 05:12:40 -0800 (PST)
Date: Fri, 16 Jan 2015 14:12:35 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [LSF/MM ATTEND] Transparent huge pages: huge tmpfs
Message-ID: <20150116131235.GW6103@redhat.com>
References: <alpine.LSU.2.11.1501152301470.7987@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1501152301470.7987@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: lsf-pc@lists.linux-foundation.org, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

Hello,

On Thu, Jan 15, 2015 at 11:54:09PM -0800, Hugh Dickins wrote:
> I would like to attend LSF/MM this year; and most of all would like
> to join Kirill Shutemov in his discussion of THP refcounting etc.

Seconded.

I'm positive about the tradeoffs coming from Kirill's simplification
of the THP refcounting by allowing to map compound pages in ptes (not
only in trans_huge_pmds) and in turn by relaxing the constraint that
split_huge_page cannot fail. It looks a worthwhile change even if it
spreads the complexity to a wider codebase and it doesn't keep it
localized in get_page/put_page anymore.

> I admit that I have not yet studied his refcounting patchset, but
> shall have done so by March.  I've been fully occupied these last
> few months with an alternative approach to THPage cache, huge tmpfs:
> starting from my belief that compound pages were ideal for hugetlbfs,
> questionable for anonymous THP, completely unsuited to THPage cache.
> 
> We shall try to work out how much we have in common, and where to go
> from there.
> 
> Huge tmpfs is currently implemented on Google's not-so-modern kernel.
> I intend to port it to v3.19 and post before LSF; but if that ends up
> like a night-before-the-conference dump of XXX patches, no, I'll spare
> you and spend more time looking at other people's work instead.

I'm interested the above topics too.

Thanks and hope to see you soon :)
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
