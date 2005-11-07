Received: from thermo.lanl.gov (thermo.lanl.gov [128.165.59.202])
	by mailwasher-b.lanl.gov (8.12.11/8.12.11/(ccn-5)) with SMTP id jA70Yv7d021298
	for <linux-mm@kvack.org>; Sun, 6 Nov 2005 17:34:58 -0700
Subject: RE: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
In-Reply-To: <01EF044AAEE12F4BAAD955CB75064943051354C4@scsmsx401.amr.corp.intel.com>
Message-Id: <20051107003452.3A0B41855A0@thermo.lanl.gov>
Date: Sun,  6 Nov 2005 17:34:52 -0700 (MST)
From: andy@thermo.lanl.gov (Andy Nelson)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ak@suse.de, nickpiggin@yahoo.com.au, rohit.seth@intel.com
Cc: akpm@osdl.org, andy@thermo.lanl.gov, arjan@infradead.org, arjanv@infradead.org, gmaxwell@gmail.com, haveblue@us.ibm.com, kravetz@us.ibm.com, lhms-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mbligh@mbligh.org, mel@csn.ul.ie, mingo@elte.hu, torvalds@osdl.org
List-ID: <linux-mm.kvack.org>

Hi folks,

>Not sure how applications seamlessly can use the proposed hugetlb zone
>based on hugetlbfs.  Depending on the programming language, it might
>actually need changes in libs/tools etc.

This is my biggest worry as well. I can't recall the details
right now, but I have some memories of people telling me, for
example, that large pages on linux were not now available to 
fortran programs period, due to lack of toolchain/lib stuff, 
just as you note. What the reasons were/are I have no idea. I 
do know that the Power 5 numbers I quoted a couple of days ago
required that the sysadmin apply some special patches to linux
and linking to extra library. I don't know what patches (they
came from ibm), but for xlf95 on Power5, the library I had to 
link with was this one:  

    -T /usr/local/lib64/elf64ppc.lbss.x


No changes were required to my code, which is what I need,
but codes that did not link to this library would not run on 
a kernel that had the patches installed, and code that did 
link with this library would not run on a kernel that didn't 
have those patches. 

I don't know what library this is or what was in it, but I 
cant imagine it would have been something very standard or
mainline, with that sort of drastic behavior. Maybe the ibm
folk can explain what this was about.


I will ask some folks here who should know how it may work
on intel/amd machines about how large pages can be used 
this coming week, when I attempt to do page size speed 
testing for my code, as I promised before, as I promised
before, as I promised before. 

Andy


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
