Date: Mon, 22 May 2006 10:52:55 +0100
Subject: [PATCH 0/2] Zone boundary alignment fixes, default configuration
Message-ID: <exportbomb.1148291574@pinky>
References: <447173EF.9090000@shadowen.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
From: Andy Whitcroft <apw@shadowen.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Mel Gorman <mel@csn.ul.ie>, stable@kernel.org, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

I think a concensus is forming that the checks for merging across
zones were removed from the buddy allocator without anyone noticing.
So I propose that the configuration option UNALIGNED_ZONE_BOUNDARIES
default to on, and those architectures which have been auditied
for alignment may turn it off.

Following this email are two patches:

zone-allow-unaligned-zone-boundaries-add-configuration -- adding
  the configuration option.

x86-add-zone-alignment-qualifier -- marking x86 as enforcing alignment.

Cheers.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
