Subject: Re: [PATCH] earlier allocation of order 0 pages from pcp in
	__alloc_pages
From: Rohit Seth <rohit.seth@intel.com>
In-Reply-To: <1128034202.6145.2.camel@localhost>
References: <20050929150155.A15646@unix-os.sc.intel.com>
	 <1128034202.6145.2.camel@localhost>
Content-Type: text/plain
Date: Thu, 29 Sep 2005 18:10:00 -0700
Message-Id: <1128042600.3735.16.camel@akash.sc.intel.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2005-09-29 at 15:50 -0700, Dave Hansen wrote:


> 
> That looks to share a decent amount of logic with the pcp code in
> buffered_rmqueue.  Any chance it could be consolidated instead of
> copy/pasting?
> 

It indeed does share most of the code with buffered_rmqueue.  And it is
definitely possible to streamline this control flow.  But that would
require more changes in the existing code (didn't want to make that as
part of this patch to start with).

-rohit

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
