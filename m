Date: Fri, 10 Oct 2008 12:42:39 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] [REPOST] mm: show node to memory section
 relationship with symlinks in sysfs
Message-Id: <20081010124239.f92b5568.akpm@linux-foundation.org>
In-Reply-To: <20081009192115.GB8793@us.ibm.com>
References: <20081009192115.GB8793@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gary Hade <garyhade@us.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, y-goto@jp.fujitsu.com, pbadari@us.ibm.com, mel@csn.ul.ie, lcm@us.ibm.com, mingo@elte.hu, greg@kroah.com, dave@linux.vnet.ibm.com, nish.aravamudan@gmail.com
List-ID: <linux-mm.kvack.org>

On Thu, 9 Oct 2008 12:21:15 -0700
Gary Hade <garyhade@us.ibm.com> wrote:

> Show node to memory section relationship with symlinks in sysfs
> 
> Add /sys/devices/system/node/nodeX/memoryY symlinks for all
> the memory sections located on nodeX.  For example:
> /sys/devices/system/node/node1/memory135 -> ../../memory/memory135
> indicates that memory section 135 resides on node1.

I'm not seeing here a description of why the kernel needs this feature.
Why is it useful?  How will it be used?  What value does it have to
our users?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
