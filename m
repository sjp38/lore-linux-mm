Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 4D2CE828E2
	for <linux-mm@kvack.org>; Wed, 10 Feb 2016 13:10:05 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id yy13so15399684pab.3
        for <linux-mm@kvack.org>; Wed, 10 Feb 2016 10:10:05 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id sj10si6508778pab.65.2016.02.10.10.10.00
        for <linux-mm@kvack.org>;
        Wed, 10 Feb 2016 10:10:01 -0800 (PST)
Subject: [PATCH 0/3] [RFC] get_user_pages_remote(), now with creative macros
From: Dave Hansen <dave@sr71.net>
Date: Wed, 10 Feb 2016 10:10:00 -0800
Message-Id: <20160210181000.886CDF18@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, torvalds@linux-foundation.org, Dave Hansen <dave@sr71.net>, srikar@linux.vnet.ibm.com, vbabka@suse.cz, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, aarcange@redhat.com, n-horiguchi@ah.jp.nec.com, jack@suse.cz

This is responding to some feedback from Ingo on the
"get_user_pages_foreign()" patch:

	http://lkml.kernel.org/r/20160209124649.GA20153@gmail.com

This new series breaks apart some of the changes in that
original patch and adds some backward-compatibility to allow
old-style get_user_pages() arguments to not break the build.
The macros to do this are "fun".  See patch #2.

We also change the name to get_user_pages_remote().

This is a preparatory patch for the Memory Protection Keys work,
but I am sending this separately for review to spare you from the
~30 other patches in the series that have not changed.

cc: srikar dronamraju <srikar@linux.vnet.ibm.com>
cc: vlastimil babka <vbabka@suse.cz>
cc: andrew morton <akpm@linux-foundation.org>
cc: kirill a. shutemov <kirill.shutemov@linux.intel.com>
cc: andrea arcangeli <aarcange@redhat.com>
cc: naoya horiguchi <n-horiguchi@ah.jp.nec.com>
cc: jack@suse.cz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
