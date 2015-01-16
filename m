Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f176.google.com (mail-we0-f176.google.com [74.125.82.176])
	by kanga.kvack.org (Postfix) with ESMTP id E59036B0032
	for <linux-mm@kvack.org>; Fri, 16 Jan 2015 07:18:25 -0500 (EST)
Received: by mail-we0-f176.google.com with SMTP id w61so19892679wes.7
        for <linux-mm@kvack.org>; Fri, 16 Jan 2015 04:18:25 -0800 (PST)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.227])
        by mx.google.com with ESMTP id t10si3835927wif.19.2015.01.16.04.18.25
        for <linux-mm@kvack.org>;
        Fri, 16 Jan 2015 04:18:25 -0800 (PST)
Date: Fri, 16 Jan 2015 14:18:20 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [LSF/MM ATTEND] Transparent huge pages: huge tmpfs
Message-ID: <20150116121820.GA29085@node.dhcp.inet.fi>
References: <alpine.LSU.2.11.1501152301470.7987@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1501152301470.7987@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: lsf-pc@lists.linux-foundation.org, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Thu, Jan 15, 2015 at 11:54:09PM -0800, Hugh Dickins wrote:
> I would like to attend LSF/MM this year; and most of all would like
> to join Kirill Shutemov in his discussion of THP refcounting etc.
> 
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

Very interesting! Looking forward for the code.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
