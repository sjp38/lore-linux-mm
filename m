Message-Id: <20080202230111.346847183@szeredi.hu>
Date: Sun, 03 Feb 2008 00:01:11 +0100
From: Miklos Szeredi <miklos@szeredi.hu>
Subject: [patch 0/3] mm: bdi: updates
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: a.p.zijlstra@chello.nl, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Here are incremental patches against the "export BDI attributes in
sysfs" patchset, addressing the issues identified at the last
submission:

  - the read-only attributes are only for debugging
  - more consistent naming needed in /sys/class/bdi
  - documentation problems

I've also done some testing, and fixed some bugs.  Including patches
in -mm can do wonders, even before the kernel containing them is
released :)

Let me know if you prefer a resubmission of the original series with
these changes folded in.

Thanks,
Miklos

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
