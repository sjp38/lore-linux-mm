Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 96C5F6B00FC
	for <linux-mm@kvack.org>; Tue,  5 Feb 2013 03:28:28 -0500 (EST)
Date: Tue, 5 Feb 2013 08:28:22 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: cma: fix accounting of CMA pages placed in high
 memory
Message-ID: <20130205082822.GE21389@suse.de>
References: <1359973626-3900-1-git-send-email-m.szyprowski@samsung.com>
 <20130204150657.6d05f76a.akpm@linux-foundation.org>
 <CAH9JG2Usd4HJKrBXwX3aEc3i6068zU=F=RjcoQ8E8uxYGrwXgg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CAH9JG2Usd4HJKrBXwX3aEc3i6068zU=F=RjcoQ8E8uxYGrwXgg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kyungmin Park <kmpark@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, minchan@kernel.org

On Tue, Feb 05, 2013 at 08:29:26AM +0900, Kyungmin Park wrote:
> >
> > (This information is needed so that others can make patch-scheduling
> > decisions and should be included in all bugfix changelogs unless it is
> > obvious).
> 
> CMA Highmem support is new feature. so don't need to go stable tree.
> 

You could have given a lot more information to that question!

How new a feature is it? Does this mean that this patch must go in before
3.8 releases or is it a fix against a patch that is only in Andrew's tree?
If the patch is only in Andrew's tree, which one is it and should this be
folded in as a fix?

On a semi-related note; is there a plan for backporting highmem support for
the LTSI kernel considering it's aimed at embedded and CMA was highlighted
in their announcment for 3.4 support?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
