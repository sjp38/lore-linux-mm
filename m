Message-Id: <20080410170232.015351000@nick.local0.net>
Date: Fri, 11 Apr 2008 03:02:32 +1000
From: npiggin@suse.de
Subject: [patch 00/17] multi size, and giant hugetlb page support, 1GB hugetlb for x86
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, pj@sgi.com, andi@firstfloor.org, kniht@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

Hi,

I'm taking care of Andi's hugetlb patchset now. I've taken a while to appear
to do anything with it because I have had other things to do and also needed
some time to get up to speed on it.

Anyway, from my reviewing of the patchset, I didn't find a great deal
wrong with it in the technical aspects. Taking hstate out of the hugetlbfs
inode and vma is really the main thing I did.

However on the less technical side, I think a few things could be improved,
eg. to do with the configuring and reporting, as well as the "administrative"
type of code. I tried to make improvements to things in the last patch of
the series. I will end up folding this properly into the rest of the patchset
where possible.

The other thing I did was try to shuffle the patches around a bit. There
were one or two (pretty trivial) points where it wasn't bisectable, and also
merge a couple of patches.

I will try to get this patchset merged in -mm soon if feedback is positive.
I would also like to take patches for other architectures or any other
patches or suggestions for improvements.

Patches are against head.

Thanks,
Nick

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
