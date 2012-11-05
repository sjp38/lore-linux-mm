Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id F24776B004D
	for <linux-mm@kvack.org>; Mon,  5 Nov 2012 18:24:13 -0500 (EST)
From: Andi Kleen <andi@firstfloor.org>
Subject: Updated MMAP/SHMGET 1GB patchkit
Date: Mon,  5 Nov 2012 15:24:07 -0800
Message-Id: <1352157848-29473-1-git-send-email-andi@firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mtk.manpages@gmail.com

This is the updated patchkit to allow to use 1GB pages for mmap/shmget
directly. This is needed for various software and makes it far more
convenient to use 1GB pages.

There were a lot of discussions on the ABI of v6 due to a conflict of
the new bits with the NOMMU only feature MAP_UNINITIALIZED.

However I don't think this matters at all because this feature
only works with HUGETLBFS and HUGETLBFS and NOMMU are mutually
exclusive. So any architecture which suppors HUGETLBFS will
never do MAP_UNINITIALIZED and vice versa. So there's no 
actual conflict in these flags.

Based on that I don't think any changes are needed.

So I decided to just repost with a rebase. 

Please consider applying,

Thanks,
-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
