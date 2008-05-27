Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m4RKhKBR010237
	for <linux-mm@kvack.org>; Tue, 27 May 2008 16:43:20 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4RKhImX076774
	for <linux-mm@kvack.org>; Tue, 27 May 2008 14:43:18 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4RKhH6o017963
	for <linux-mm@kvack.org>; Tue, 27 May 2008 14:43:18 -0600
Subject: Re: [patch 04/23] hugetlb: multiple hstates
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <20080525143452.518017000@nick.local0.net>
References: <20080525142317.965503000@nick.local0.net>
	 <20080525143452.518017000@nick.local0.net>
Content-Type: text/plain
Date: Tue, 27 May 2008 15:43:16 -0500
Message-Id: <1211920997.12036.13.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: linux-mm@kvack.org, kniht@us.ibm.com, andi@firstfloor.org, nacc@us.ibm.com, abh@cray.com, joachim.deguara@amd.com, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

On Mon, 2008-05-26 at 00:23 +1000, npiggin@suse.de wrote:
> plain text document attachment (hugetlb-multiple-hstates.patch)
> Add basic support for more than one hstate in hugetlbfs
> 
> - Convert hstates to an array
> - Add a first default entry covering the standard huge page size
> - Add functions for architectures to register new hstates
> - Add basic iterators over hstates
> 
> Signed-off-by: Andi Kleen <ak@suse.de>
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
