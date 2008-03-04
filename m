From: Christoph Lameter <clameter@sgi.com>
Subject: [rfc 00/10] [Patch] Page flags: Cleanup, reorg and introduce 5 new flags
Date: Mon, 03 Mar 2008 16:04:52 -0800
Message-ID: <20080304000452.514878384@sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754001AbYCDAII@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, apw@shadowen.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

A set of patches that attempts to improve page flag handling. First of all a
method is introduced to generate the page flag functions using macros. Then
the number of page flags used by sparsemem is reduced. All page flag
operations will no longer be macros. All flags will use inline function.

Then we add a way to export enum constants to the preprocessor which allows
us to get rid of __ZONE_COUNT and use the NR_PAGEFLAGS for the dynamic
calculation of actually available page flags for fields.

Optimization of sparsemem vmemmap allows us to avoid the use of page flags
for section ids. The newly available flags are taken for various ongoing
VM projects.

RFC->V1
- Fix various things as suggested by Mel and Kame-san.
- Avoid the #idef CONFIG_PAGEFLAG_EXTENDED. The new page flags
  are always available.

-- 
