Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e31.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j0QEfEm4374284
	for <linux-mm@kvack.org>; Wed, 26 Jan 2005 09:41:14 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j0QEfEtB445186
	for <linux-mm@kvack.org>; Wed, 26 Jan 2005 07:41:14 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id j0QEfD9r028773
	for <linux-mm@kvack.org>; Wed, 26 Jan 2005 07:41:13 -0700
Date: Wed, 26 Jan 2005 06:37:16 -0800
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: [RFC][PATCH 0/5] consolidate i386 NUMA init code
Message-ID: <15640000.1106750236@flay>
In-Reply-To: <1106698985.6093.39.camel@localhost>
References: <1106698985.6093.39.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> The following five patches reorganize and consolidate some of the i386
> NUMA/discontigmem code.  They grew out of some observations as we
> produced the memory hotplug patches.
> 
> Only the first one is really necessary, as it makes the implementation
> of one of the hotplug components much simpler and smaller.  2 and 3 came
> from just looking at the effects on the code after 1.
> 
> 4 and 5 aren't absolutely required for hotplug either, but do allow
> sharing a bunch of code between the normal boot-time init and hotplug
> cases.  
> 
> These are all on top of 2.6.11-rc2-mm1.

Looks reasonable. How much testing have they had, on what platforms?

M
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
