Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 211606B0037
	for <linux-mm@kvack.org>; Thu,  6 Jun 2013 05:05:38 -0400 (EDT)
Date: Thu, 6 Jun 2013 10:05:34 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 2/7] mm: compaction: scan all memory with
 /proc/sys/vm/compact_memory
Message-ID: <20130606090534.GD1936@suse.de>
References: <1370445037-24144-1-git-send-email-aarcange@redhat.com>
 <1370445037-24144-3-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1370445037-24144-3-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rafael Aquini <aquini@redhat.com>

On Wed, Jun 05, 2013 at 05:10:32PM +0200, Andrea Arcangeli wrote:
> Reset the stats so /proc/sys/vm/compact_memory will scan all memory.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
