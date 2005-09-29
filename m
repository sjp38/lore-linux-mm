Date: Thu, 29 Sep 2005 15:36:26 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] earlier allocation of order 0 pages from pcp in
 __alloc_pages
Message-Id: <20050929153626.3ab4fce1.akpm@osdl.org>
In-Reply-To: <20050929150155.A15646@unix-os.sc.intel.com>
References: <20050929150155.A15646@unix-os.sc.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Seth, Rohit" <rohit.seth@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

"Seth, Rohit" <rohit.seth@intel.com> wrote:
>
> 	[PATCH]: Try to service a order 0 page request in __alloc_pages from the pcp list before checking the aone_watermarks.
>
>         Try to service a order 0 page request from pcp list.  This will allow us to not check and possibly start the reclaim activity when there are free pages present on the pcp.  This early allocation does not try to replenish an empty pcp.

(Please avoid the 240-column emails!)

Why is this a desirable change to make?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
