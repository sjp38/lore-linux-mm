Message-Id: <20080525142317.965503000@nick.local0.net>
Date: Mon, 26 May 2008 00:23:17 +1000
From: npiggin@suse.de
Subject: [patch 00/23] multi size, giant hugetlb support, 1GB for x86, 16GB for powerpc
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: kniht@us.ibm.com, andi@firstfloor.org, nacc@us.ibm.com, agl@us.ibm.com, abh@cray.com, joachim.deguara@amd.com
List-ID: <linux-mm.kvack.org>

Hi all,

Given the amount of feedback this has had, and the powerpc patches from Jon,
I'll send out one more request for review and testing before asking Andrew
to merge in -mm.

Patches are against Linus's current git (eb90d81d). I will have to rebase
to -mm next.

The patches pass the libhugetlbfs regression test suite here on x86 and
powerpc (although my G5 can only run 16MB hugepages, so it is less
interesting...).

So, review and testing welcome.

Thanks!
Nick

-- 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
