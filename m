Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 63B726B0078
	for <linux-mm@kvack.org>; Thu,  5 Nov 2009 15:21:26 -0500 (EST)
Subject: [PATCH v2 2/3] page-types: whitespace alignment
From: Alex Chiang <achiang@hp.com>
Date: Thu, 05 Nov 2009 13:21:21 -0700
Message-ID: <20091105202121.25492.26616.stgit@bob.kio>
In-Reply-To: <20091105201846.25492.52935.stgit@bob.kio>
References: <20091105201846.25492.52935.stgit@bob.kio>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org, fengguang.wu@intel.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Align the output when page-type -h is invoked.

Signed-off-by: Alex Chiang <achiang@hp.com>
---

 Documentation/vm/page-types.c |   46 +++++++++++++++++++++--------------------
 1 files changed, 23 insertions(+), 23 deletions(-)

diff --git a/Documentation/vm/page-types.c b/Documentation/vm/page-types.c
index a93c28e..9c09eb5 100644
--- a/Documentation/vm/page-types.c
+++ b/Documentation/vm/page-types.c
@@ -673,35 +673,35 @@ static void usage(void)
 
 	printf(
 "page-types [options]\n"
-"            -r|--raw                  Raw mode, for kernel developers\n"
+"            -r|--raw                   Raw mode, for kernel developers\n"
 "            -d|--describe flags        Describe flags\n"
-"            -a|--addr    addr-spec    Walk a range of pages\n"
-"            -b|--bits    bits-spec    Walk pages with specified bits\n"
-"            -p|--pid     pid          Walk process address space\n"
+"            -a|--addr     addr-spec    Walk a range of pages\n"
+"            -b|--bits     bits-spec    Walk pages with specified bits\n"
+"            -p|--pid      pid          Walk process address space\n"
 #if 0 /* planned features */
-"            -f|--file    filename     Walk file address space\n"
+"            -f|--file     filename     Walk file address space\n"
 #endif
-"            -l|--list                 Show page details in ranges\n"
-"            -L|--list-each            Show page details one by one\n"
-"            -N|--no-summary           Don't show summay info\n"
-"            -X|--hwpoison             hwpoison pages\n"
-"            -x|--unpoison             unpoison pages\n"
-"            -h|--help                 Show this usage message\n"
+"            -l|--list                  Show page details in ranges\n"
+"            -L|--list-each             Show page details one by one\n"
+"            -N|--no-summary            Don't show summary info\n"
+"            -X|--hwpoison              hwpoison pages\n"
+"            -x|--unpoison              unpoison pages\n"
+"            -h|--help                  Show this usage message\n"
 "flags:\n"
-"            0x10                      bitfield format, e.g.\n"
-"            anon                      bit-name, e.g.\n"
-"            0x10,anon                 comma-separated list, e.g.\n"
+"            0x10                       bitfield format, e.g.\n"
+"            anon                       bit-name, e.g.\n"
+"            0x10,anon                  comma-separated list, e.g.\n"
 "addr-spec:\n"
-"            N                         one page at offset N (unit: pages)\n"
-"            N+M                       pages range from N to N+M-1\n"
-"            N,M                       pages range from N to M-1\n"
-"            N,                        pages range from N to end\n"
-"            ,M                        pages range from 0 to M-1\n"
+"            N                          one page at offset N (unit: pages)\n"
+"            N+M                        pages range from N to N+M-1\n"
+"            N,M                        pages range from N to M-1\n"
+"            N,                         pages range from N to end\n"
+"            ,M                         pages range from 0 to M-1\n"
 "bits-spec:\n"
-"            bit1,bit2                 (flags & (bit1|bit2)) != 0\n"
-"            bit1,bit2=bit1            (flags & (bit1|bit2)) == bit1\n"
-"            bit1,~bit2                (flags & (bit1|bit2)) == bit1\n"
-"            =bit1,bit2                flags == (bit1|bit2)\n"
+"            bit1,bit2                  (flags & (bit1|bit2)) != 0\n"
+"            bit1,bit2=bit1             (flags & (bit1|bit2)) == bit1\n"
+"            bit1,~bit2                 (flags & (bit1|bit2)) == bit1\n"
+"            =bit1,bit2                 flags == (bit1|bit2)\n"
 "bit-names:\n"
 	);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
