Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m4RHF5W5029720
	for <linux-mm@kvack.org>; Tue, 27 May 2008 13:15:05 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4RHEsb1088172
	for <linux-mm@kvack.org>; Tue, 27 May 2008 11:14:56 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4RHErNM022248
	for <linux-mm@kvack.org>; Tue, 27 May 2008 11:14:54 -0600
Date: Tue, 27 May 2008 10:14:52 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [patch 22/23] fs: check for statfs overflow
Message-ID: <20080527171452.GJ20709@us.ibm.com>
References: <20080525142317.965503000@nick.local0.net> <20080525143454.453947000@nick.local0.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080525143454.453947000@nick.local0.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: linux-mm@kvack.org, kniht@us.ibm.com, andi@firstfloor.org, agl@us.ibm.com, abh@cray.com, joachim.deguara@amd.com, Jon Tollefson <kniht@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On 26.05.2008 [00:23:39 +1000], npiggin@suse.de wrote:
> Adds a check for an overflow in the filesystem size so if someone is
> checking with statfs() on a 16G hugetlbfs  in a 32bit binary that it
> will report back EOVERFLOW instead of a size of 0.
> 
> Are other places that need a similar check?  I had tried a similar
> check in put_compat_statfs64 too but it didn't seem to generate an
> EOVERFLOW in my test case.

I think this part of the changelog was meant to be a post-"---"
question, which I don't have an answer for, but probably shouldn't go in
the final changelog?

> Signed-off-by: Jon Tollefson <kniht@linux.vnet.ibm.com>
> Signed-off-by: Nick Piggin <npiggin@suse.de>

Acked-by: Nishanth Aravamudan <nacc@us.ibm.com>

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
