Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k3QC3fxd025940
	for <linux-mm@kvack.org>; Wed, 26 Apr 2006 08:03:41 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k3QC7AtY183518
	for <linux-mm@kvack.org>; Wed, 26 Apr 2006 06:07:10 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id k3QC3e7r026605
	for <linux-mm@kvack.org>; Wed, 26 Apr 2006 06:03:40 -0600
Message-ID: <444F619A.2030002@watson.ibm.com>
Date: Wed, 26 Apr 2006 08:03:38 -0400
From: Hubertus Franke <frankeh@watson.ibm.com>
MIME-Version: 1.0
Subject: Re: Page host virtual assist patches.
References: <20060424123412.GA15817@skybase>	 <20060424180138.52e54e5c.akpm@osdl.org>  <444DCD87.2030307@yahoo.com.au>	 <1145953914.5282.21.camel@localhost>  <444DF447.4020306@yahoo.com.au>	 <1145964531.5282.59.camel@localhost>  <444E1253.9090302@yahoo.com.au>	 <1145974521.5282.89.camel@localhost>  <444EC953.6060309@yahoo.com.au> <1146037185.5192.3.camel@localhost>
In-Reply-To: <1146037185.5192.3.camel@localhost>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: schwidefsky@de.ibm.com
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, rhim@cc.gatech.edu
List-ID: <linux-mm.kvack.org>

Martin Schwidefsky wrote:
> On Wed, 2006-04-26 at 11:13 +1000, Nick Piggin wrote:
> 
>>OK, we'll agree to disagree for now :)
>>
>>I did start looking at the code but as you can see I only reviewed
>>patch 1 before getting sidetracked. I'll try to find some more time
>>to look at in the next few days.
> 
> 
> Thanks Nick, that would be greatly appreciated. The code is hard to
> understand, it's memory races squared. Races of the hypervisor actions
> against races in the Linux mm. Lovely. It took use quite a while to get
> that beast working, on z/VM, Linux and the millicode. 
> 

Martin, one thing that should be pointed out that despite these race
conditions, the principle concept is rather clean.
It's like putting a lock at the right place, you got to know what is
protected.

If the documentation is not clear, then lets change it.
As I see, you have not included the Documentation part into the latest
patch submission. I think doing that will help.

Kernel writers should understand when they need to make the page stable
when they should attempt to make it volatile, when the system does it for them
due to the page_cache_release.
In most cases, those functions are burried in the lower level functions already.
It just gets a bit hairy with LRU races.

Nick,  your feedback on what is not clear, would help us properly address that in
the documentation.
As for code impact, I consider this very similar to the KMAP interface.
There's not need it for 64-bit architectures, but the interface is clean and
optimized away by the compiler. The same holds true here, as Martin pointed
out there is no change in the code when disabled (one exception, not on the critical
part).

-- Hubertus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
