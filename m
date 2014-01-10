Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f169.google.com (mail-ea0-f169.google.com [209.85.215.169])
	by kanga.kvack.org (Postfix) with ESMTP id A68566B0031
	for <linux-mm@kvack.org>; Fri, 10 Jan 2014 12:42:10 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id l9so1852282eaj.0
        for <linux-mm@kvack.org>; Fri, 10 Jan 2014 09:42:10 -0800 (PST)
Received: from kirsi1.inet.fi (mta-out.inet.fi. [195.156.147.13])
        by mx.google.com with ESMTP id p46si1170118eem.210.2014.01.10.09.42.09
        for <linux-mm@kvack.org>;
        Fri, 10 Jan 2014 09:42:09 -0800 (PST)
Date: Fri, 10 Jan 2014 19:42:04 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [Lsf-pc] [LSF/MM ATTEND] Memory management -- THP, hugetlb,
 scalability
Message-ID: <20140110174204.GA5228@node.dhcp.inet.fi>
References: <20140103122509.GA18786@node.dhcp.inet.fi>
 <20140108151321.GI27046@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140108151321.GI27046@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Matthew Wilcox <willy@linux.intel.com>

On Wed, Jan 08, 2014 at 03:13:21PM +0000, Mel Gorman wrote:
> On Fri, Jan 03, 2014 at 02:25:09PM +0200, Kirill A. Shutemov wrote:
> > Hi,
> > 
> > I would like to attend LSF/MM summit. I'm interested in discussion about
> > huge pages, scalability of memory management subsystem and persistent
> > memory.
> > 
> > Last year I did some work to fix THP-related regressions and improve
> > scalability. I also work on THP for file-backed pages.
> > 
> > Depending on project status, I probably want to bring transparent huge
> > pagecache as a topic.
> > 
> 
> I think transparent huge pagecache is likely to crop up for more than one
> reason. There is the TLB issue and the motivation that i-TLB pressure is
> a problem in some specialised cases. Whatever the merits of that case,
> transparent hugepage cache has been raised as a potential solution for
> some VM scalability problems. I recognise that dealing with large numbers
> of struct pages is now a problem on larger machines (although I have not
> seen quantified data on the problem nor do I have access to a machine large
> enough to measure it myself) but I'm wary of transparent hugepage cache
> being treated as a primary solution for VM scalability problems. Lacking
> performance data I have no suggestions on what these alternative solutions
> might look like.

Yes, performance data is critical. I'll try bring some.

The only alternative I see is some kind of THP, implemented on filesystem
level. It can work for tmpfs/shm reasonably well. But it looks ad-hoc and
in long term transparent huge pagecache is the way to go, I believe.

Sibling topic is THP for XIP (see Matthew's patchset). Guys want to manage
persistent memory in 2M chunks where it's possible. And THP (but without
struct page in this case) is the obvious solution.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
