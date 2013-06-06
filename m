Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 8FD8B6B0031
	for <linux-mm@kvack.org>; Thu,  6 Jun 2013 05:19:14 -0400 (EDT)
Date: Thu, 6 Jun 2013 10:19:10 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 5/7] mm: compaction: increase the high order pages in the
 watermarks
Message-ID: <20130606091910.GG1936@suse.de>
References: <1370445037-24144-1-git-send-email-aarcange@redhat.com>
 <1370445037-24144-6-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1370445037-24144-6-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rafael Aquini <aquini@redhat.com>

On Wed, Jun 05, 2013 at 05:10:35PM +0200, Andrea Arcangeli wrote:
> Require more high order pages in the watermarks, to give more margin
> for concurrent allocations. If there are too few pages, they can
> disappear too soon.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

This seems to be special casing THP allocations to allow it to relax the
watermark requirements. FWIW, I have seen cases where hugepage
allocations fail even though there are pages free becase memory is low
overall. It was very marginal though in terms of overall success rates
but that was also a long time ago when I was checking. How much of a
difference did you see with this patch?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
