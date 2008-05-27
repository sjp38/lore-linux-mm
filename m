Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m4RKp0Rh025219
	for <linux-mm@kvack.org>; Tue, 27 May 2008 16:51:00 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4RKp0fY136804
	for <linux-mm@kvack.org>; Tue, 27 May 2008 16:51:00 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4RKoxJJ016962
	for <linux-mm@kvack.org>; Tue, 27 May 2008 16:51:00 -0400
Subject: Re: [patch 06/23] hugetlbfs: per mount hstates
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <20080525143452.733810000@nick.local0.net>
References: <20080525142317.965503000@nick.local0.net>
	 <20080525143452.733810000@nick.local0.net>
Content-Type: text/plain
Date: Tue, 27 May 2008 15:50:59 -0500
Message-Id: <1211921459.12036.15.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: linux-mm@kvack.org, kniht@us.ibm.com, andi-suse@firstfloor.org, nacc@us.ibm.com, abh@cray.com, joachim.deguara@amd.com, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

On Mon, 2008-05-26 at 00:23 +1000, npiggin@suse.de wrote:
> plain text document attachment (hugetlbfs-per-mount-hstate.patch)
> Add support to have individual hstates for each hugetlbfs mount
> 
> - Add a new pagesize= option to the hugetlbfs mount that allows setting
> the page size
> - Set up pointers to a suitable hstate for the set page size option
> to the super block and the inode and the vma.
> - Change the hstate accessors to use this information
> - Add code to the hstate init function to set parsed_hstate for command
> line processing
> - Handle duplicated hstate registrations to the make command line user proof
> 
> [np: take hstate out of hugetlbfs inode and vma->vm_private_data]
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
