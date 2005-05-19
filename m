Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j4JEs29o001279
	for <linux-mm@kvack.org>; Thu, 19 May 2005 10:54:02 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j4JEs1W5120052
	for <linux-mm@kvack.org>; Thu, 19 May 2005 10:54:01 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j4JEs1gG018604
	for <linux-mm@kvack.org>; Thu, 19 May 2005 10:54:01 -0400
Subject: Re: [patch 2/4] add x86-64 Kconfig options for sparsemem
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20050518165358.GF88141@muc.de>
References: <200505181643.j4IGhm7S026977@snoqualmie.dp.intel.com>
	 <20050518165358.GF88141@muc.de>
Content-Type: text/plain
Date: Thu, 19 May 2005 07:53:44 -0700
Message-Id: <1116514424.26955.119.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@muc.de>
Cc: Matt Tolentino <metolent@snoqualmie.dp.intel.com>, Andrew Morton <akpm@osdl.org>, Andy Whitcroft <apw@shadowen.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2005-05-18 at 18:53 +0200, Andi Kleen wrote:
> Hmm, I would have assumed IBM tested it, since Dave Hansen signed off - 
> they have a range of Opteron machines.   If not I can test it
> on a few boxes later.

I actually don't personally have any access to Opteron machines.  But, I
know Keith Mannthey has been testing it all along on his various x86_64
machines.  I'll certainly make sure we get another run on all of those
once it goes into -mm.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
