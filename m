Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m4RGVGso007772
	for <linux-mm@kvack.org>; Tue, 27 May 2008 12:31:16 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4RGVGrt149774
	for <linux-mm@kvack.org>; Tue, 27 May 2008 12:31:16 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4RGVFt2021732
	for <linux-mm@kvack.org>; Tue, 27 May 2008 12:31:16 -0400
Date: Tue, 27 May 2008 09:31:14 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [patch 02/23] hugetlb: factor out huge_new_page
Message-ID: <20080527163114.GB20709@us.ibm.com>
References: <20080525142317.965503000@nick.local0.net> <20080525143452.345341000@nick.local0.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080525143452.345341000@nick.local0.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: linux-mm@kvack.org, kniht@us.ibm.com, andi@firstfloor.org, agl@us.ibm.com, abh@cray.com, joachim.deguara@amd.com
List-ID: <linux-mm.kvack.org>

On 26.05.2008 [00:23:19 +1000], npiggin@suse.de wrote:
> Needed to avoid code duplication in follow up patches.
> 
> Signed-off-by: Andi Kleen <ak@suse.de>
> Signed-off-by: Nick Piggin <npiggin@suse.de>

Acked-by: Nishanth Aravamudan <nacc@us.ibm.com>

Although the e-mail subject does not match the name of the function :)

And can probably be sent upstream without the other patches as well.

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
