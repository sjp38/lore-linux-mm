Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9PIlQKe007419
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 14:47:26 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9PIlQJH096044
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 14:47:26 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9PIlP5e016030
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 14:47:25 -0400
Subject: Re: RFC/POC Make Page Tables Relocatable
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <d43160c70710251144t172cfd1exef99e0d53fb9be73@mail.gmail.com>
References: <d43160c70710250816l44044f31y6dd20766d1f2840b@mail.gmail.com>
	 <1193330774.4039.136.camel@localhost>
	 <d43160c70710251040u23feeaf9l16fafc2685b2ce52@mail.gmail.com>
	 <1193335725.24087.19.camel@localhost>
	 <d43160c70710251144t172cfd1exef99e0d53fb9be73@mail.gmail.com>
Content-Type: text/plain
Date: Thu, 25 Oct 2007 11:47:23 -0700
Message-Id: <1193338043.24087.24.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ross Biro <rossb@google.com>
Cc: linux-mm@kvack.org, Mel Gorman <MELGOR@ie.ibm.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2007-10-25 at 14:44 -0400, Ross Biro wrote:
> This is why I asked for some micro
> benchmarks.  I figured people would send the ones they feel are most
> likely to fail.

lmbench has some fault speed tests that are pretty sensitive to things
like changes in the allocator.  You might take a look at those.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
