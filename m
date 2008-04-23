Message-Id: <20080423015302.745723000@nick.local0.net>
Date: Wed, 23 Apr 2008 11:53:02 +1000
From: npiggin@suse.de
Subject: [patch 00/18] multi size, and giant hugetlb page support, 1GB hugetlb for x86
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, andi@firstfloor.org, kniht@linux.vnet.ibm.com, nacc@us.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

Hi

Patches 1 and 2 are good to merge upstream now. Patch 3 I hope gets merged
too. After Andrew's big upstream merge, and this round of review, I plan
push the reset of the patchset into -mm. It would be very nice to have the
powerpc patches integrated and tested by that point too -- is there something
I can pick up?

I'm again not sure of the sysfs work. I think this patchset probably actually
does make sense to go in first, because it will necessarily change the
layout of the sysfs directories.

I have integrated bounds fixes, and type size fixes suggested by reviewers.
Merged those and my previous round of fixes into the previous patches in
the patchset.

Have done a little bit more juggling of the patchset (without changing the end
result but trying to improve the steps).

Then I have done another set of fixes in the last patch of the patchset,
which will again be merged after review.

Testing-wise, I've changed the registration mechanism so that if you specify
hugepagesz=1G on the command line, then you do not get the 2M pages by default
(you have to also specify hugepagesz=2M). Also, when only one hstate is
registered, all the proc outputs appear unchanged, so this makes it very easy
to test with.

Thanks,
Nick

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
