Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m4RGV7Jj025150
	for <linux-mm@kvack.org>; Tue, 27 May 2008 12:31:07 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m4RGUvq8031584
	for <linux-mm@kvack.org>; Tue, 27 May 2008 10:30:58 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4RGUu6M025327
	for <linux-mm@kvack.org>; Tue, 27 May 2008 10:30:56 -0600
Date: Tue, 27 May 2008 09:30:54 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [patch 01/23] hugetlb: fix lockdep error
Message-ID: <20080527163054.GA20709@us.ibm.com>
References: <20080525142317.965503000@nick.local0.net> <20080525143452.193337000@nick.local0.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080525143452.193337000@nick.local0.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: linux-mm@kvack.org, kniht@us.ibm.com, andi@firstfloor.org, agl@us.ibm.com, abh@cray.com, joachim.deguara@amd.com
List-ID: <linux-mm.kvack.org>

On 26.05.2008 [00:23:18 +1000], npiggin@suse.de wrote:
> Signed-off-by: Nick Piggin <npiggin@suse.de>

Acked-by: Nishanth Aravamudan <nacc@us.ibm.com>

And can probably go upstream independent of the rest?

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
