Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id CD5AD6B0035
	for <linux-mm@kvack.org>; Fri, 20 Jun 2014 03:52:35 -0400 (EDT)
Received: by mail-pb0-f49.google.com with SMTP id rr13so2823442pbb.22
        for <linux-mm@kvack.org>; Fri, 20 Jun 2014 00:52:35 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id mi7si8800237pab.136.2014.06.20.00.52.34
        for <linux-mm@kvack.org>;
        Fri, 20 Jun 2014 00:52:34 -0700 (PDT)
Date: Fri, 20 Jun 2014 15:52:18 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [mmotm:master 153/230] lib/glob.c:48:32: sparse: Using plain integer
 as NULL pointer
Message-ID: <20140620075218.GA3059@localhost>
References: <53a3cf27.i2H5zBcGy/9VGAAt%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53a3cf27.i2H5zBcGy/9VGAAt%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: George Spelvin <linux@horizon.com>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   df25ba7db0775d87018e2cd92f26b9b087093840
commit: 31b8d64a94ed8129048a904cc07c11a05c2efd6f [153/230] libata: Use glob_match from lib/glob.c
reproduce: make C=1 CF=-D__CHECK_ENDIAN__

>> lib/glob.c:48:32: sparse: Using plain integer as NULL pointer

vim +48 lib/glob.c

37e65fe1 George Spelvin 2014-06-20  32   * treat / or leading . specially; it isn't actually used for pathnames.
37e65fe1 George Spelvin 2014-06-20  33   *
37e65fe1 George Spelvin 2014-06-20  34   * Note that according to glob(7) (and unlike bash), character classes
37e65fe1 George Spelvin 2014-06-20  35   * are complemented by a leading !; this does not support the regex-style
37e65fe1 George Spelvin 2014-06-20  36   * [^a-z] syntax.
37e65fe1 George Spelvin 2014-06-20  37   *
37e65fe1 George Spelvin 2014-06-20  38   * An opening bracket without a matching close is matched literally.
37e65fe1 George Spelvin 2014-06-20  39   */
37e65fe1 George Spelvin 2014-06-20  40  bool __pure glob_match(char const *pat, char const *str)
37e65fe1 George Spelvin 2014-06-20  41  {
37e65fe1 George Spelvin 2014-06-20  42  	/*
37e65fe1 George Spelvin 2014-06-20  43  	 * Backtrack to previous * on mismatch and retry starting one
37e65fe1 George Spelvin 2014-06-20  44  	 * character later in the string.  Because * matches all characters
37e65fe1 George Spelvin 2014-06-20  45  	 * (no exception for /), it can be easily proved that there's
37e65fe1 George Spelvin 2014-06-20  46  	 * never a need to backtrack multiple levels.
37e65fe1 George Spelvin 2014-06-20  47  	 */
37e65fe1 George Spelvin 2014-06-20 @48  	char const *back_pat = 0, *back_str = back_str;
37e65fe1 George Spelvin 2014-06-20  49  
37e65fe1 George Spelvin 2014-06-20  50  	/*
37e65fe1 George Spelvin 2014-06-20  51  	 * Loop over each token (character or class) in pat, matching
37e65fe1 George Spelvin 2014-06-20  52  	 * it against the remaining unmatched tail of str.  Return false
37e65fe1 George Spelvin 2014-06-20  53  	 * on mismatch, or true after matching the trailing nul bytes.
37e65fe1 George Spelvin 2014-06-20  54  	 */
37e65fe1 George Spelvin 2014-06-20  55  	for (;;) {
37e65fe1 George Spelvin 2014-06-20  56  		unsigned char c = *str++;



---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
