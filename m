Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e34.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j0QIAWaQ426326
	for <linux-mm@kvack.org>; Wed, 26 Jan 2005 13:10:32 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j0QIAWtB456122
	for <linux-mm@kvack.org>; Wed, 26 Jan 2005 11:10:32 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id j0QIAVrv012103
	for <linux-mm@kvack.org>; Wed, 26 Jan 2005 11:10:31 -0700
Date: Wed, 26 Jan 2005 09:53:39 -0800
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: [RFC][PATCH 0/5] consolidate i386 NUMA init code
Message-ID: <2410000.1106762019@flay>
In-Reply-To: <1106762509.6093.67.camel@localhost>
References: <1106698985.6093.39.camel@localhost>  <15640000.1106750236@flay> <1106762509.6093.67.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> Built on all the i386 configs here:
> http://sr71.net/patches/2.6.11/2.6.11-rc1-mm1-mhp1/configs/
> 
> Booted on x440 (summit and generic), numaq, 4-way PIII.  I would imagine
> that any problem would manifest as the system simply not booting.  The
> most likely to fail would be systems with DISCONTIG enabled, because
> that's where the greatest amount of churn happened.  The normal !
> DISCONTIG case still uses most of the same code.
> 
> Anyway, I think they're probably ready for a run in -mm, with the "if
> the machines don't boot check these first" flag set.  Although, I'd
> appreciate any other testing that anyone wants to throw at them.

Yup, as long as they boot, is probably good enough for now.

Thanks,

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
