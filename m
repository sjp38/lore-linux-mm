Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k7PFpWSQ008404
	for <linux-mm@kvack.org>; Fri, 25 Aug 2006 11:51:32 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k7PFpWhV240506
	for <linux-mm@kvack.org>; Fri, 25 Aug 2006 09:51:32 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7PFpWK2027879
	for <linux-mm@kvack.org>; Fri, 25 Aug 2006 09:51:32 -0600
Subject: Re: [RFC][PATCH] unify all architecture PAGE_SIZE definitions
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <Pine.LNX.4.64.0608250838410.9083@schroedinger.engr.sgi.com>
References: <20060824234430.6AC970F7@localhost.localdomain>
	 <Pine.LNX.4.64.0608250838410.9083@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Fri, 25 Aug 2006 08:51:22 -0700
Message-Id: <1156521082.12011.182.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2006-08-25 at 08:42 -0700, Christoph Lameter wrote:
> I think this is a good thing to do. However, the patch as it is now is 
> difficult to review. Could you split the patch into multiple patches? One 
> patch that introduces the generic functionality and then do one patch 
> per arch? It would be best to sent the arch specific patches to the arch 
> mailing list or the arch maintainer for review.
> 
> You probably can get the generic piece into mm together with the first 
> arch specific patch (once the first arch has signed off) and then submit 
> further bits as the reviews get completed.

It _is_ too big.  However, I think doing 24 different architectures
separately would probably be a major pain, and never get done.  It would
also have to create some temporary Kconfig names (or give up the names
it uses now, which duplicate some arch code).

How about this: I'll split it up, one patch for each of the difficult
architectures: parisc, mips, sparc64, ia64, one patch for the 4k-only
page architectures, and we'll look at what's left?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
