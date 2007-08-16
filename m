Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by ausmtp06.au.ibm.com (8.13.8/8.13.8) with ESMTP id l7G5R5jV3104946
	for <linux-mm@kvack.org>; Thu, 16 Aug 2007 15:27:05 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7G5No4L4243552
	for <linux-mm@kvack.org>; Thu, 16 Aug 2007 15:23:50 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7G6NnGt030893
	for <linux-mm@kvack.org>; Thu, 16 Aug 2007 16:23:49 +1000
Date: Thu, 16 Aug 2007 15:12:56 +1000
From: David Gibson <dwg@au1.ibm.com>
Subject: Re: [Documentation] Page Table Layout diagrams
Message-ID: <20070816051256.GF3540@localhost.localdomain>
References: <1186598865.23817.76.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1186598865.23817.76.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, linuxppc-dev@ozlabs.org, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Aug 08, 2007 at 01:47:45PM -0500, Adam Litke wrote:
> Hello all.  In an effort to understand how the page tables are laid out
> across various architectures I put together some diagrams.  I have
> posted them on the linux-mm wiki: http://linux-mm.org/PageTableStructure
> and I hope they will be useful to others.  
> 
> Just to make sure I am not spreading misinformation, could a few of you
> experts take a quick look at the three diagrams I've got finished so far
> and point out any errors I have made?  Thanks.

Nice.  Didn't spot any innaccuracies.

-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
