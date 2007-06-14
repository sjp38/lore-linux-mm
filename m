Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5EDLP7r014980
	for <linux-mm@kvack.org>; Thu, 14 Jun 2007 09:21:25 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5EEOEmi547048
	for <linux-mm@kvack.org>; Thu, 14 Jun 2007 10:24:14 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5EEOEAB029132
	for <linux-mm@kvack.org>; Thu, 14 Jun 2007 10:24:14 -0400
Date: Thu, 14 Jun 2007 07:24:12 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [RFC 00/13] RFC memoryless node handling fixes
Message-ID: <20070614142412.GC7469@us.ibm.com>
References: <20070614075026.607300756@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070614075026.607300756@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 14.06.2007 [00:50:26 -0700], clameter@sgi.com wrote:
> This has now become a longer series since I have seen a couple of
> things in various places where we do not take into account memoryless
> nodes.
> 
> I changed the GFP_THISNODE fix to generate a new set of zonelists.
> GFP_THISNODE will then simply use a zonelist that only has the zones
> of the node.
> 
> I have only tested this by booting on a IA64 simulator. Please review.
> I do not have a real system with a memoryless node.

I do :) -- will stack your patches on rc4-mm2 and rebase my patches on
top to test.

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
