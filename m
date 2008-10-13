Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m9DGedil014216
	for <linux-mm@kvack.org>; Mon, 13 Oct 2008 12:40:39 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m9DGec1s201886
	for <linux-mm@kvack.org>; Mon, 13 Oct 2008 10:40:38 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m9DGebPn003331
	for <linux-mm@kvack.org>; Mon, 13 Oct 2008 10:40:38 -0600
Subject: Re: [PATCH 1/2] [REPOST] mm: show node to memory section
	relationship with symlinks in sysfs
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20081013163416.GA7340@us.ibm.com>
References: <20081009192115.GB8793@us.ibm.com>
	 <20081010124239.f92b5568.akpm@linux-foundation.org>
	 <20081010213357.GD7369@us.ibm.com>
	 <20081010145950.f51def29.akpm@linux-foundation.org>
	 <20081010231844.GA1718@us.ibm.com>
	 <20081010163230.ae9d964d.akpm@linux-foundation.org>
	 <20081013163416.GA7340@us.ibm.com>
Content-Type: text/plain
Date: Mon, 13 Oct 2008 09:40:35 -0700
Message-Id: <1223916035.29877.10.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gary Hade <garyhade@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, y-goto@jp.fujitsu.com, pbadari@us.ibm.com, mel@csn.ul.ie, lcm@us.ibm.com, mingo@elte.hu, greg@kroah.com, nish.aravamudan@gmail.com
List-ID: <linux-mm.kvack.org>

On Mon, 2008-10-13 at 09:34 -0700, Gary Hade wrote:
> I understand your concerns about adding possibly frivolous interfaces
> but in this case we are simply eliminating a very obvious hole in the
> existing set of memory hot-add/remove interfaces.  In general, it
> makes absolutely no sense to provide a resource add/remove mechanism
> without telling the user where the resource is physically located.

Does it help we export the phys_index (basically the section number) as
part of the section directory?

I don't think we export the physical memory ranges of NUMA nodes.  But,
if we did that as well, it would allow userspace to do this association
without troubling the kernel with maintaining it.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
