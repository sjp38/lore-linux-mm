Message-ID: <481183FC.9060408@firstfloor.org>
Date: Fri, 25 Apr 2008 09:10:52 +0200
From: Andi Kleen <andi@firstfloor.org>
MIME-Version: 1.0
Subject: Re: [patch 02/18] hugetlb: factor out huge_new_page
References: <20080423015302.745723000@nick.local0.net> <20080423015429.834926000@nick.local0.net> <20080424235431.GB4741@us.ibm.com> <20080424235829.GC4741@us.ibm.com>
In-Reply-To: <20080424235829.GC4741@us.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: npiggin@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org, kniht@linux.vnet.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

Nishanth Aravamudan wrote:
> On 24.04.2008 [16:54:31 -0700], Nishanth Aravamudan wrote:
>> On 23.04.2008 [11:53:04 +1000], npiggin@suse.de wrote:
>>> Needed to avoid code duplication in follow up patches.
>>>
>>> This happens to fix a minor bug. When alloc_bootmem_node returns
>>> a fallback node on a different node than passed the old code
>>> would have put it into the free lists of the wrong node.
>>> Now it would end up in the freelist of the correct node.
>> This is rather frustrating. The whole point of having the __GFP_THISNODE
>> flag is to indicate off-node allocations are *not* supported from the
>> caller... This was all worked on quite heavily a while back.

Perhaps it was, but the result in hugetlb.c was not correct.

> Oh I see. This patch refers to a bug that only is introduced by patch
> 12/18...perhaps *that* patch should add the nid calculation in the
> helper, if it is truly needed.

No, the bug is already there even without the bootmem patch.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
