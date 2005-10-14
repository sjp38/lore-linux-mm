Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id j9E5XaXv025691
	for <linux-mm@kvack.org>; Fri, 14 Oct 2005 01:33:36 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j9E5bZau547900
	for <linux-mm@kvack.org>; Thu, 13 Oct 2005 23:37:35 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j9E5aj3u013015
	for <linux-mm@kvack.org>; Thu, 13 Oct 2005 23:36:45 -0600
Subject: Re: [PATCH 6/8] Fragmentation Avoidance V17:
	006_largealloc_tryharder
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <434EB058.8090809@austin.ibm.com>
References: <20051011151221.16178.67130.sendpatchset@skynet.csn.ul.ie>
	 <20051011151251.16178.24064.sendpatchset@skynet.csn.ul.ie>
	 <434EB058.8090809@austin.ibm.com>
Content-Type: text/plain
Date: Thu, 13 Oct 2005 22:36:27 -0700
Message-Id: <1129268188.22903.34.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Joel Schopp <jschopp@austin.ibm.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@osdl.org>, kravetz@us.ibm.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, lhms <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

On Thu, 2005-10-13 at 14:07 -0500, Joel Schopp wrote:
> This is version 17, plus several versions I did while Mel was preoccupied with 
> his day job, makes well over 20 times this has been posted to the mailing lists 
> that are lkml, linux-mm, and memory hotplug.
> 
> All objections/feedback/suggestions that have been brought up on the lists are 
> fixed in the following version.  It's starting to become almost silent when a 
> new version gets posted, possibly because everybody accepts the code as perfect, 
> possibly because they have grown bored with it.  Probably a combination of both.

I don't think it's shown signs of stabilizing quite yet.  Each revision
has new code that needs to be cleaned up, and new obvious CodingStyle
issues.  Let's see a couple of incrementally cleaner releases go by,
which don't have renewed old issues, and then we can think about asking
to get it merged elsewhere.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
