Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id iB2IKWQf069788
	for <linux-mm@kvack.org>; Thu, 2 Dec 2004 13:20:32 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id iB2IKWGj341868
	for <linux-mm@kvack.org>; Thu, 2 Dec 2004 11:20:32 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id iB2IKVig025616
	for <linux-mm@kvack.org>; Thu, 2 Dec 2004 11:20:32 -0700
Reply-To: Gerrit Huizenga <gh@us.ibm.com>
From: Gerrit Huizenga <gh@us.ibm.com>
Subject: Re: page fault scalability patch V12 [0/7]: Overview and performance tests 
In-reply-to: Your message of Thu, 02 Dec 2004 10:10:29 PST.
             <20041202101029.7fe8b303.cliffw@osdl.org>
Date: Thu, 02 Dec 2004 10:17:55 -0800
Message-Id: <E1CZvWd-0001hv-00@w-gerrit.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: cliff white <cliffw@osdl.org>
Cc: Jeff Garzik <jgarzik@pobox.com>, mbligh@aracnet.com, akpm@osdl.org, torvalds@osdl.org, clameter@sgi.com, hugh@veritas.com, benh@kernel.crashing.org, nickpiggin@yahoo.com.au, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 02 Dec 2004 10:10:29 PST, cliff white wrote:
> On Thu, 02 Dec 2004 02:31:35 -0500
> Jeff Garzik <jgarzik@pobox.com> wrote:
> 
> > Martin J. Bligh wrote:
> > > Yeah, probably. Though the stress tests catch a lot more than the 
> > > functionality ones. The big pain in the ass is drivers, because I don't
> > > have a hope in hell of testing more than 1% of them.
> > 
> > My dream is that hardware vendors rotate their current machines through 
> > a test shop :)  It would be nice to make sure that the popular drivers 
> > get daily test coverage.
> > 
> > 	Jeff, dreaming on
> 
> OSDL has recently re-done the donation policy, and we're much better positioned
> to support that sort of thing now - Contact Tom Hanrahan at OSDL if you 
> are a vendor, or know a vendor. ( Or you can become a vendor ) 

Specifically Tom Hanrahan == hanrahat@osdl.org

gerrit
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
