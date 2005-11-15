From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 5/5] Light Fragmentation Avoidance V20: 005_configurable
Date: Wed, 16 Nov 2005 00:39:20 +0100
References: <20051115164946.21980.2026.sendpatchset@skynet.csn.ul.ie> <20051115165012.21980.51131.sendpatchset@skynet.csn.ul.ie>
In-Reply-To: <20051115165012.21980.51131.sendpatchset@skynet.csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200511160039.21243.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, mingo@elte.hu, linux-kernel@vger.kernel.org, nickpiggin@yahoo.com.au, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Tuesday 15 November 2005 17:50, Mel Gorman wrote:
> The anti-defragmentation strategy has memory overhead. This patch allows
> the strategy to be disabled for small memory systems or if it is known the
> workload is suffering because of the strategy. It also acts to show where
> the anti-defrag strategy interacts with the standard buddy allocator.

If anything this should be a boot time option or perhaps sysctl, not a config.
In general CONFIGs that change runtime behaviour are evil - just makes
changing the option more painful, causes problems for distribution
users, doesn't make much sense, etc.etc.

Also #ifdef as a documentation device is a really really scary concept.
Yuck.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
