Date: Thu, 23 Aug 2007 19:29:45 -0500
From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH 9/9] pagemap: export swap ptes
Message-ID: <20070824002945.GE21720@waste.org>
References: <20070822231804.1132556D@kernel> <20070822231814.8F5F37A0@kernel>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070822231814.8F5F37A0@kernel>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 22, 2007 at 04:18:14PM -0700, Dave Hansen wrote:
> 
> In addition to understanding which physical pages are
> used by a process, it would also be very nice to
> enumerate how much swap space a process is using.
> 
> This patch enables /proc/<pid>/pagemap to display
> swap ptes.  In the process, it also changes the
> constant that we used to indicate non-present ptes
> before.
> 
> Signed-off-by: Dave Hansen <haveblue@us.ibm.com>

I suspect you missed a quilt add here, as is_swap_pte is not in any
header file and is thus implicitly declared.

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
