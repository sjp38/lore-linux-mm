Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id C695C6B0394
	for <linux-mm@kvack.org>; Wed, 15 Mar 2017 22:00:23 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id 20so41511500iod.2
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 19:00:23 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0014.hostedemail.com. [216.40.44.14])
        by mx.google.com with ESMTPS id u128si4674277iod.99.2017.03.15.19.00.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Mar 2017 19:00:23 -0700 (PDT)
From: Joe Perches <joe@perches.com>
Subject: [PATCH 00/15] mm: page_alloc: style neatenings
Date: Wed, 15 Mar 2017 18:59:57 -0700
Message-Id: <cover.1489628477.git.joe@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

Just neatening.  Maybe useful, maybe not.  Mostly whitespace changes.

There are still many checkpatch messages that should probably
be ignored.

Before:
$ ./scripts/checkpatch.pl --strict --terse --nosummary --show-types \
	-f mm/page_alloc.c | \
  cut -f4 -d":" | sort | uniq -c | sort -rn
    144 PARENTHESIS_ALIGNMENT
     38 SPLIT_STRING
     36 LINE_SPACING
     32 LONG_LINE
     28 SPACING
     14 LONG_LINE_COMMENT
     14 BRACES
     13 LOGGING_CONTINUATION
     12 PREFER_PR_LEVEL
      8 MISPLACED_INIT
      7 EXPORT_SYMBOL
      7 AVOID_BUG
      6 UNSPECIFIED_INT
      5 MACRO_ARG_PRECEDENCE
      4 MULTIPLE_ASSIGNMENTS
      4 LOGICAL_CONTINUATIONS
      4 COMPARISON_TO_NULL
      4 CAMELCASE
      3 UNNECESSARY_PARENTHESES
      3 PRINTK_WITHOUT_KERN_LEVEL
      3 MACRO_ARG_REUSE
      2 UNDOCUMENTED_SETUP
      2 MEMORY_BARRIER
      2 BLOCK_COMMENT_STYLE
      1 VOLATILE
      1 TYPO_SPELLING
      1 SYMBOLIC_PERMS
      1 SUSPECT_CODE_INDENT
      1 SPACE_BEFORE_TAB
      1 FUNCTION_ARGUMENTS
      1 CONSTANT_COMPARISON
      1 CONSIDER_KSTRTO

After:
$ ./scripts/checkpatch.pl --strict --terse --nosummary --show-types \
	-f mm/page_alloc.c | \
  cut -f4 -d":" | sort | uniq -c | sort -rn
     43 SPLIT_STRING
     21 LONG_LINE
     14 LONG_LINE_COMMENT
     13 LOGGING_CONTINUATION
     12 PREFER_PR_LEVEL
      8 PRINTK_WITHOUT_KERN_LEVEL
      7 AVOID_BUG
      5 MACRO_ARG_PRECEDENCE
      4 MULTIPLE_ASSIGNMENTS
      4 CAMELCASE
      3 MACRO_ARG_REUSE
      2 UNDOCUMENTED_SETUP
      2 MEMORY_BARRIER
      2 LEADING_SPACE
      1 VOLATILE
      1 SPACING
      1 FUNCTION_ARGUMENTS
      1 EXPORT_SYMBOL
      1 CONSTANT_COMPARISON
      1 CONSIDER_KSTRTO

Joe Perches (15):
  mm: page_alloc: whitespace neatening
  mm: page_alloc: align arguments to parenthesis
  mm: page_alloc: fix brace positions
  mm: page_alloc: fix blank lines
  mm: page_alloc: Move __meminitdata and __initdata uses
  mm: page_alloc: Use unsigned int instead of unsigned
  mm: page_alloc: Move labels to column 1
  mm: page_alloc: Fix typo acording -> according & the the -> to the
  mm: page_alloc: Use the common commenting style
  mm: page_alloc: 80 column neatening
  mm: page_alloc: Move EXPORT_SYMBOL uses
  mm: page_alloc: Avoid pointer comparisons to NULL
  mm: page_alloc: Remove unnecessary parentheses
  mm: page_alloc: Use octal permissions
  mm: page_alloc: Move logical continuations to EOL

 mm/page_alloc.c | 845 ++++++++++++++++++++++++++++++--------------------------
 1 file changed, 458 insertions(+), 387 deletions(-)

-- 
2.10.0.rc2.1.g053435c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
