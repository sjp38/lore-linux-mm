Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 48AE86B0033
	for <linux-mm@kvack.org>; Thu,  6 Jun 2013 05:14:54 -0400 (EDT)
Date: Thu, 6 Jun 2013 10:14:48 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 4/7] mm: compaction: reset before initializing the scan
 cursors
Message-ID: <20130606091448.GF1936@suse.de>
References: <1370445037-24144-1-git-send-email-aarcange@redhat.com>
 <1370445037-24144-5-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1370445037-24144-5-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rafael Aquini <aquini@redhat.com>

On Wed, Jun 05, 2013 at 05:10:34PM +0200, Andrea Arcangeli wrote:
> Otherwise the first iteration of compaction after restarting it, will
> only do a partial scan.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Whoops!

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
