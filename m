Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k8FGWdT6014461
	for <linux-mm@kvack.org>; Fri, 15 Sep 2006 12:32:39 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k8FGWdER276450
	for <linux-mm@kvack.org>; Fri, 15 Sep 2006 12:32:39 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k8FGWdQL013419
	for <linux-mm@kvack.org>; Fri, 15 Sep 2006 12:32:39 -0400
Subject: Re: [PATCH] Get rid of zone_table
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <450AAA83.3040905@shadowen.org>
References: <Pine.LNX.4.64.0609131340050.19059@schroedinger.engr.sgi.com>
	 <1158180795.9141.158.camel@localhost.localdomain>
	 <Pine.LNX.4.64.0609131425010.19380@schroedinger.engr.sgi.com>
	 <1158184047.9141.164.camel@localhost.localdomain>
	 <450AAA83.3040905@shadowen.org>
Content-Type: text/plain
Date: Fri, 15 Sep 2006 09:32:30 -0700
Message-Id: <1158337950.24414.24.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2006-09-15 at 14:28 +0100, Andy Whitcroft wrote:
> The section table only contains an adjusted pointer to the mem_map for
> that section?  We use the bottom two bits of that pointer for a couple
> of flags.  I don't think there is any space in it.

For x86, we don't need very many bits.  Maybe four.  We also don't use a
very large number of sections on x86.  That should leave space in the
mem_section[] pointer.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
