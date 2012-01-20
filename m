Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id E92016B004D
	for <linux-mm@kvack.org>; Fri, 20 Jan 2012 17:03:45 -0500 (EST)
Date: Fri, 20 Jan 2012 14:03:44 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/5] staging: zsmalloc: memory allocator for compressed
 pages
Message-Id: <20120120140344.2fb399e4.akpm@linux-foundation.org>
In-Reply-To: <1326149520-31720-1-git-send-email-sjenning@linux.vnet.ibm.com>
References: <1326149520-31720-1-git-send-email-sjenning@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@suse.de>, Dan Magenheimer <dan.magenheimer@oracle.com>, Brian King <brking@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Konrad Wilk <konrad.wilk@oracle.com>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

On Mon,  9 Jan 2012 16:51:55 -0600
Seth Jennings <sjenning@linux.vnet.ibm.com> wrote:

> This patchset introduces a new memory allocation library named
> zsmalloc.  zsmalloc was designed to fulfill the needs
> of users where:
>  1) Memory is constrained, preventing contiguous page allocations
>     larger than order 0 and
>  2) Allocations are all/commonly greater than half a page.
> 
> In a generic allocator, an allocation set like this would
> cause high fragmentation.  The allocations can't span non-
> contiguous page boundaries; therefore, the part of the page
> unused by each allocation is wasted.
> 
> zsmalloc is a slab-based allocator that uses a non-standard
> malloc interface, requiring the user to map the allocation
> before accessing it. This allows allocations to span two
> non-contiguous pages using virtual memory mapping, greatly
> reducing fragmentation in the memory pool.

The changelog doesn't really describe why the code was written and
provides no reason for anyone to merge it.

Perhaps the reason was to clean up and generalise the zram xvmalloc
code.  Perhaps the reason was also to then use zsmalloc somewhere else
in the kernel.  But I really don't know.  This is the most important
part of the patch description and you completely omitted it!


Where will this code live after it escapes from drivers/staging/? mm/?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
