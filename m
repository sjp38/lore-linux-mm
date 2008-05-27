Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m4RGwukq016109
	for <linux-mm@kvack.org>; Tue, 27 May 2008 12:58:56 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4RGwmJ31552494
	for <linux-mm@kvack.org>; Tue, 27 May 2008 12:58:49 -0400
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4RGwl8M011384
	for <linux-mm@kvack.org>; Tue, 27 May 2008 10:58:48 -0600
Date: Tue, 27 May 2008 09:58:46 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [patch 06/23] hugetlbfs: per mount hstates
Message-ID: <20080527165846.GE20709@us.ibm.com>
References: <20080525142317.965503000@nick.local0.net> <20080525143452.733810000@nick.local0.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080525143452.733810000@nick.local0.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: linux-mm@kvack.org, kniht@us.ibm.com, andi@firstfloor.org, agl@us.ibm.com, abh@cray.com, joachim.deguara@amd.com, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

On 26.05.2008 [00:23:23 +1000], npiggin@suse.de wrote:
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
