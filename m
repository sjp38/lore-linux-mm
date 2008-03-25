Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m2PIRi0n015715
	for <linux-mm@kvack.org>; Tue, 25 Mar 2008 14:27:44 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2PIRiG6241980
	for <linux-mm@kvack.org>; Tue, 25 Mar 2008 14:27:44 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2PIRig7030595
	for <linux-mm@kvack.org>; Tue, 25 Mar 2008 14:27:44 -0400
Subject: Re: larger default page sizes...
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <18408.29107.709577.374424@cargo.ozlabs.ibm.com>
References: <Pine.LNX.4.64.0803211037140.18671@schroedinger.engr.sgi.com>
	 <20080321.145712.198736315.davem@davemloft.net>
	 <Pine.LNX.4.64.0803241121090.3002@schroedinger.engr.sgi.com>
	 <20080324.133722.38645342.davem@davemloft.net>
	 <18408.29107.709577.374424@cargo.ozlabs.ibm.com>
Content-Type: text/plain
Date: Tue, 25 Mar 2008 11:27:45 -0700
Message-Id: <1206469665.27393.19.camel@nimitz.home.sr71.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Mackerras <paulus@samba.org>
Cc: David Miller <davem@davemloft.net>, clameter@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Tue, 2008-03-25 at 14:29 +1100, Paul Mackerras wrote:
> 4kB pages:      444.051s user + 34.406s system time
> 64kB pages:     419.963s user + 16.869s system time
> 
> That's nearly 10% faster with 64kB pages -- on a kernel compile.

Can you do the same thing with the 4k MMU pages and 64k PAGE_SIZE?
Wouldn't that easily break out whether the advantage is from the TLB or
from less kernel overhead?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
