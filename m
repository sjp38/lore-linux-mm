Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e36.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id jB20DAKc001776
	for <linux-mm@kvack.org>; Thu, 1 Dec 2005 19:13:10 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id jB20CaSI066506
	for <linux-mm@kvack.org>; Thu, 1 Dec 2005 17:12:36 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id jB20D98C009874
	for <linux-mm@kvack.org>; Thu, 1 Dec 2005 17:13:10 -0700
Subject: Re: Better pagecache statistics ?
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <Pine.LNX.4.62.0512011310030.25135@schroedinger.engr.sgi.com>
References: <1133377029.27824.90.camel@localhost.localdomain>
	 <20051201152029.GA14499@dmt.cnet> <20051201160044.GB14499@dmt.cnet>
	 <Pine.LNX.4.62.0512011310030.25135@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Thu, 01 Dec 2005 16:13:20 -0800
Message-Id: <1133482400.21429.69.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Marcelo Tosatti <marcelo.tosatti@cyclades.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2005-12-01 at 13:16 -0800, Christoph Lameter wrote:
> We are actually looking at have better pagecache statistics and I have 
> been trying out a series of approaches. The direct need right now is to 
> have some statistics on the size of the pagecache and the number of 
> unmapped file backed pages per node.
> 

Cool. I would be interested in it. Where are you collecting the
statistics ?

Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
