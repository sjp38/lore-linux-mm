Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m4RLdCXC024902
	for <linux-mm@kvack.org>; Tue, 27 May 2008 17:39:12 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4RLdBGx099124
	for <linux-mm@kvack.org>; Tue, 27 May 2008 15:39:11 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4RLd7fW012681
	for <linux-mm@kvack.org>; Tue, 27 May 2008 15:39:10 -0600
Subject: Re: [patch 17/23] hugetlb: do not always register default
	HPAGE_SIZE huge page size
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <20080525143453.921204000@nick.local0.net>
References: <20080525142317.965503000@nick.local0.net>
	 <20080525143453.921204000@nick.local0.net>
Content-Type: text/plain
Date: Tue, 27 May 2008 16:39:03 -0500
Message-Id: <1211924343.12036.47.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: linux-mm@kvack.org, kniht@us.ibm.com, andi-suse@firstfloor.org, nacc@us.ibm.com, abh@cray.com, joachim.deguara@amd.com
List-ID: <linux-mm.kvack.org>

On Mon, 2008-05-26 at 00:23 +1000, npiggin@suse.de wrote:
> plain text document attachment (hugetlb-non-default-hstate.patch)
> Allow configurations without the default HPAGE_SIZE size (mainly useful for
> testing -- the final form of the userspace API / cmdline is not quite
> nailed down).
> 
> Signed-off-by: Nick Piggin <npiggin@suse.de>

Acked-by: Adam Litke <agl@us.ibm.com>

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
