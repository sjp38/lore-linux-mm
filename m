Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 2A58B6B0031
	for <linux-mm@kvack.org>; Thu,  6 Jun 2013 06:09:15 -0400 (EDT)
Date: Thu, 6 Jun 2013 11:09:11 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 0/7] RFC: adding compaction to zone_reclaim_mode > 0
Message-ID: <20130606100911.GI1936@suse.de>
References: <1370445037-24144-1-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1370445037-24144-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rafael Aquini <aquini@redhat.com>

On Wed, Jun 05, 2013 at 05:10:30PM +0200, Andrea Arcangeli wrote:
> <SNIP>
> The main change of behavior is the removal of compact_blockskip_flush
> and the __reset_isolation_suitable immediately executed when a
> compaction pass completes and the slightly increased amount of
> hugepages required to meet the low/min watermarks. The rest of the
> changes mostly applies to zone_reclaim_mode > 0 and doesn't affect the
> default 0 value (some large system may boot with zone_reclaim_mode set
> to 1 by default though, if the node distance is very high).
> 

I'm fine with patches 2, 3 and 4 which make sense independant of the rest
of the series. I'm less sure of the rest of the series. Can 2, 3 and 4 be
split out and sent separately and then treat 1, 5, 6 and 7 exclusively as
a zone_reclaim set please?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
