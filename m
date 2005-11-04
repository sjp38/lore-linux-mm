Received: from thermo.lanl.gov (thermo.lanl.gov [128.165.59.202])
	by mailwasher-b.lanl.gov (8.12.11/8.12.11/(ccn-5)) with SMTP id jA4GEOHB001149
	for <linux-mm@kvack.org>; Fri, 4 Nov 2005 09:14:24 -0700
Subject: Re: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
In-Reply-To: <Pine.LNX.4.64.0511040738540.27915@g5.osdl.org>
Message-Id: <20051104161420.9CFA8184631@thermo.lanl.gov>
Date: Fri,  4 Nov 2005 09:14:20 -0700 (MST)
From: andy@thermo.lanl.gov (Andy Nelson)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: andy@thermo.lanl.gov, torvalds@osdl.org
Cc: akpm@osdl.org, arjan@infradead.org, arjanv@infradead.org, haveblue@us.ibm.com, kravetz@us.ibm.com, lhms-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mbligh@mbligh.org, mel@csn.ul.ie, mingo@elte.hu, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

Linus:

>> If your and other kernel developer's (<<0.01% of the universe) kernel
>> builds slow down by 5% and my and other people's simulations (perhaps 
>> 0.01% of the universe) speed up by a factor up to 3 or 4, who wins? 
>
>First off, you won't speed up by a factor of three or four. Not even 
>_close_. 

My measurements of factors of 3-4 on more than one hw arch don't
mean anything then? BTW: Ingo Molnar has a response that did find 
my comp.arch posts. As I indicated to him, I've done a lot of code
tuning to get better performance even in the presence of tlb issues.
This factor is what is left. Starting from an untuned code, the factor
can be up to an order of magnitude larger. As in 30-60. Yes, I've
measured that too, though these detailed measurments were only on
mips/origins.


It is true that I have never had the opportunity to test these
issues on x86 and its relatives. Perhaps it would be better there.
The relative insensitivity of the results I have already to hw 
arch, indicate otherwise though.


Re maintainability: Fine. I like maintainable code too. Coding
standards are great. Language standards are even better.

These are motherhood statements. Your simple rejections
("NO, HELL NO!!") even of any attempts to make these sorts
of improvements seems to make that issue pretty moot anyway. 



Andy


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
