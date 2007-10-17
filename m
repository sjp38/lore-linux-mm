Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9HGDVpk031420
	for <linux-mm@kvack.org>; Wed, 17 Oct 2007 12:13:31 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9HGDCcu424754
	for <linux-mm@kvack.org>; Wed, 17 Oct 2007 10:13:13 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9HGDBIH021244
	for <linux-mm@kvack.org>; Wed, 17 Oct 2007 10:13:11 -0600
Subject: Re: During VM oom condition, kill all threads in process group
From: Will Schmidt <will_schmidt@vnet.ibm.com>
Reply-To: will_schmidt@vnet.ibm.com
In-Reply-To: <20071016224147.GB29378@wotan.suse.de>
References: <20071016224147.GB29378@wotan.suse.de>
Content-Type: text/plain
Date: Wed, 17 Oct 2007 11:13:08 -0500
Message-Id: <1192637589.18159.372.camel@farscape.rchland.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Anton Blanchard <anton@samba.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-10-17 at 00:41 +0200, Nick Piggin wrote:
> Hi,
> 
Hi Nick, 

> What architecture, filesystems, and workload did you observe problems with?
> Did you discover which allocation was failing?

Powerpc architecture, running GPFS.   Sadly, I dont have any real
details on the workload that actually generated the oom condition, so
dont know what allocation was failing, etc.

> I have a patch for this, but wasn't really pushing it hard because it's
> pretty unlikely for x86 and standard filesystems to oom from here...

Yeah, I suspect pretty unlikely for any architecture to get there.
Powerpc in addition to x86 anyway..  :-)   For my test purposes I added
debug code to force taking that code path.

Thanks,
-Will

> Thanks,
> Nick
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
