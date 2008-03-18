Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m2IE7WYl015761
	for <linux-mm@kvack.org>; Tue, 18 Mar 2008 10:07:32 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2IE8Qw6245128
	for <linux-mm@kvack.org>; Tue, 18 Mar 2008 08:08:28 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2IE8EaC025262
	for <linux-mm@kvack.org>; Tue, 18 Mar 2008 08:08:14 -0600
Subject: Re: [PATCH] [6/18] Add support to have individual hstates for each
	hugetlbfs mount
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <20080317015819.E7ECB1B41E0@basil.firstfloor.org>
References: <20080317258.659191058@firstfloor.org>
	 <20080317015819.E7ECB1B41E0@basil.firstfloor.org>
Content-Type: text/plain
Date: Tue, 18 Mar 2008 09:10:06 -0500
Message-Id: <1205849406.10849.89.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, pj@sgi.com, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

On Mon, 2008-03-17 at 02:58 +0100, Andi Kleen wrote:
> - Add a new pagesize= option to the hugetlbfs mount that allows setting
> the page size
> - Set up pointers to a suitable hstate for the set page size option
> to the super block and the inode and the vma.
> - Change the hstate accessors to use this information
> - Add code to the hstate init function to set parsed_hstate for command
> line processing
> - Handle duplicated hstate registrations to the make command line user proof
> 
> Signed-off-by: Andi Kleen <ak@suse.de>

FWIW, I think this approach is definitely the way to go for supporting
multiple huge page sizes.

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
