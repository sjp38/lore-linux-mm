Message-Id: <20050808201416.450491000@jumble.boston.redhat.com>
Date: Mon, 08 Aug 2005 16:14:16 -0400
From: Rik van Riel <riel@redhat.com>
Subject: [RFC 0/3] non-resident page tracking
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

These patches implement non-resident page tracking, which is needed
infrastructure for advanced page replacement algorithms like CART
and CLOCK-Pro.

The patches have been tested, but could use some eyeballs.  In
particular, I do not know if the chosen hash function gives a good
spread between the hash buckets.

Note that these patches are not very useful by themselves, I still
need to implement CLOCK-Pro on top of them.  For more information
please see the linux-mm wiki:

	http://linux-mm.org/wiki/AdvancedPageReplacement

-- 
All Rights Reversed
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
