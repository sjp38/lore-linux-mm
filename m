Date: Tue, 4 Mar 2003 18:10:02 -0500
From: Benjamin LaHaise <bcrl@redhat.com>
Subject: Re: [PATCH] remove __pte_offset
Message-ID: <20030304181002.A16110@redhat.com>
References: <3E653012.5040503@us.ibm.com> <3E6530B3.2000906@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3E6530B3.2000906@us.ibm.com>; from haveblue@us.ibm.com on Tue, Mar 04, 2003 at 03:03:15PM -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Andrew Morton <akpm@digeo.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 04, 2003 at 03:03:15PM -0800, Dave Hansen wrote:
> ptes this time

Isn't pte_to_pfn a better name?  index doesn't have a type of data 
implied, whereas pfn does.  We have to make these distinctions clearer 
as work like William's PAGE_SIZE is being done.

		-ben
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
