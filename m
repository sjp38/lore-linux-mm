Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Subject: RE: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
Date: Fri, 4 Nov 2005 17:52:29 -0800
Message-ID: <01EF044AAEE12F4BAAD955CB75064943051354DA@scsmsx401.amr.corp.intel.com>
From: "Seth, Rohit" <rohit.seth@intel.com>
Sender: owner-linux-mm@kvack.org
From: Linus Torvalds Sent: Friday, November 04, 2005 8:01 AM
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>, Andy Nelson <andy@thermo.lanl.gov>
Cc: akpm@osdl.org, arjan@infradead.org, arjanv@infradead.org, haveblue@us.ibm.com, kravetz@us.ibm.com, lhms-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mbligh@mbligh.org, mel@csn.ul.ie, mingo@elte.hu, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>


>If I remember correctly, ia64 used to suck horribly because Linux had
to 
>use a mode where the hw page table walker didn't work well (maybe it
was 
>just an itanium 1 bug), but should be better now. But x86 probably
kicks 
>its butt.

I don't remember a difference of more than (roughly) 30 percentage
points even on first generation Itaniums (using hugetlb vs normal
pages). And few more percentage points when walker was disabled. Over
time the page table walker on IA-64 has gotten more aggressive.


...though I believe that 30% is a lot of performance.

-rohit

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
