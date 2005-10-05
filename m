Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j95HpMV9024750
	for <linux-mm@kvack.org>; Wed, 5 Oct 2005 13:51:22 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j95HpMt2079504
	for <linux-mm@kvack.org>; Wed, 5 Oct 2005 13:51:22 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j95HpMR7013507
	for <linux-mm@kvack.org>; Wed, 5 Oct 2005 13:51:22 -0400
Subject: Re: [PATCH 3/7] Fragmentation Avoidance V16: 003_fragcore
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <Pine.LNX.4.58.0510051834250.16421@skynet>
References: <20051005144546.11796.1154.sendpatchset@skynet.csn.ul.ie>
	 <20051005144602.11796.53850.sendpatchset@skynet.csn.ul.ie>
	 <1128530908.26009.28.camel@localhost>
	 <Pine.LNX.4.58.0510051812040.16421@skynet>
	 <1128532920.26009.43.camel@localhost>
	 <Pine.LNX.4.58.0510051834250.16421@skynet>
Content-Type: text/plain
Date: Wed, 05 Oct 2005 10:51:10 -0700
Message-Id: <1128534670.26009.48.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, kravetz@us.ibm.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, jschopp@austin.ibm.com, lhms <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

On Wed, 2005-10-05 at 18:45 +0100, Mel Gorman wrote:
> The problem is that by putting all the changes to this function in another
> patch, the kernel will not build after applying 003_fragcore. I am
> assuming that is bad. I think it makes sense to leave this patch as it is,
> but have a 004_showfree patch that adds the type_names[] array and a more
> detailed printout in show_free_areas. The remaining patches get bumped up
> a number.
> 
> Would you be happy with that?

Seems reasonable to me.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
