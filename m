Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id B4B326B004D
	for <linux-mm@kvack.org>; Mon, 29 Jun 2009 21:03:01 -0400 (EDT)
Date: Tue, 30 Jun 2009 09:03:02 +0800
From: Shaohua Li <shaohua.li@intel.com>
Subject: Re: +
	memory-hotplug-exclude-isolated-page-from-pco-page-alloc.patch
	added to -mm tree
Message-ID: <20090630010302.GD21254@sli10-desk.sh.intel.com>
References: <200906291949.n5TJnrsO028716@imap1.linux-foundation.org> <alpine.DEB.1.10.0906291818460.21956@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0906291818460.21956@gentwo.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "mel@csn.ul.ie" <mel@csn.ul.ie>, "Zhao, Yakui" <yakui.zhao@intel.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 30, 2009 at 06:20:00AM +0800, Christoph Lameter wrote:
> On Mon, 29 Jun 2009, akpm@linux-foundation.org wrote:
> 
> > Pages marked as isolated should not be allocated again.  If such pages
> > reside in pcp list, they can be allocated too, so there is a ping-pong
> > memory offline frees some pages to pcp list and the pages get allocated
> > and then memory offline frees them again, this loop will happen again and
> > again.
> 
> Isolated pages are freed? Could they not be kept on a separate
> list with refcount elevated until the isolation procedure is complete?
Yes, they can be freed and add into pcp list. Moving them to a separate list
is feasible, but the approach is more intrusive to me. As I explained in the
patch, adding check in buffered_rmqueue() should hasn't impact for normal path.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
