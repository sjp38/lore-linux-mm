Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f171.google.com (mail-ea0-f171.google.com [209.85.215.171])
	by kanga.kvack.org (Postfix) with ESMTP id EFDD16B0037
	for <linux-mm@kvack.org>; Wed,  8 Jan 2014 10:13:24 -0500 (EST)
Received: by mail-ea0-f171.google.com with SMTP id h10so875619eak.2
        for <linux-mm@kvack.org>; Wed, 08 Jan 2014 07:13:24 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e48si93655324eeh.71.2014.01.08.07.13.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 08 Jan 2014 07:13:24 -0800 (PST)
Date: Wed, 8 Jan 2014 15:13:21 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [Lsf-pc] [LSF/MM ATTEND] Memory management -- THP, hugetlb,
 scalability
Message-ID: <20140108151321.GI27046@suse.de>
References: <20140103122509.GA18786@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20140103122509.GA18786@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Fri, Jan 03, 2014 at 02:25:09PM +0200, Kirill A. Shutemov wrote:
> Hi,
> 
> I would like to attend LSF/MM summit. I'm interested in discussion about
> huge pages, scalability of memory management subsystem and persistent
> memory.
> 
> Last year I did some work to fix THP-related regressions and improve
> scalability. I also work on THP for file-backed pages.
> 
> Depending on project status, I probably want to bring transparent huge
> pagecache as a topic.
> 

I think transparent huge pagecache is likely to crop up for more than one
reason. There is the TLB issue and the motivation that i-TLB pressure is
a problem in some specialised cases. Whatever the merits of that case,
transparent hugepage cache has been raised as a potential solution for
some VM scalability problems. I recognise that dealing with large numbers
of struct pages is now a problem on larger machines (although I have not
seen quantified data on the problem nor do I have access to a machine large
enough to measure it myself) but I'm wary of transparent hugepage cache
being treated as a primary solution for VM scalability problems. Lacking
performance data I have no suggestions on what these alternative solutions
might look like.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
