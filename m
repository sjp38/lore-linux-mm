Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m6UGTxXU008740
	for <linux-mm@kvack.org>; Wed, 30 Jul 2008 12:29:59 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m6UGTxQx177826
	for <linux-mm@kvack.org>; Wed, 30 Jul 2008 12:29:59 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m6UGTv78013391
	for <linux-mm@kvack.org>; Wed, 30 Jul 2008 12:29:58 -0400
Subject: Re: sparcemem or discontig?
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <4890957F.6080705@sciatl.com>
References: <488F5D5F.9010006@sciatl.com> <1217368281.13228.72.camel@nimitz>
	 <20080730093552.GD1369@brain>  <4890957F.6080705@sciatl.com>
Content-Type: text/plain
Date: Wed, 30 Jul 2008 09:29:53 -0700
Message-Id: <1217435393.18919.18.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: C Michael Sundius <Michael.sundius@sciatl.com>
Cc: Andy Whitcroft <apw@shadowen.org>, linux-mm@kvack.org, msundius@sundius.com
List-ID: <linux-mm.kvack.org>

On Wed, 2008-07-30 at 09:23 -0700, C Michael Sundius wrote:
> Pardon my ignorance, but is sparcemem independent of the bootmem allocator?

Yes, it really don't have much to do with bootmem.

> We also use highmem. I noticed that all of our kmap and kmap_atomic code 
> is located
> in the arch/mips directory. Is the sparcemem also independent of that? 
> should I expect
> that I will have to make some changes in that...

No, I don't think you'll need any changes to those.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
