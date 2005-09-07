Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j87HTDPV014411
	for <linux-mm@kvack.org>; Wed, 7 Sep 2005 13:29:13 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j87HTApu080530
	for <linux-mm@kvack.org>; Wed, 7 Sep 2005 13:29:13 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j87HTAnp010149
	for <linux-mm@kvack.org>; Wed, 7 Sep 2005 13:29:10 -0400
Subject: Re: [PATCH] i386: single node SPARSEMEM fix
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20050906035531.31603.46449.sendpatchset@cherry.local>
References: <20050906035531.31603.46449.sendpatchset@cherry.local>
Content-Type: text/plain
Date: Wed, 07 Sep 2005 10:28:36 -0700
Message-Id: <1126114116.7329.16.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Magnus Damm <magnus@valinux.co.jp>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "A. P. Whitcroft [imap]" <andyw@uk.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2005-09-06 at 12:56 +0900, Magnus Damm wrote:
> This patch for 2.6.13-git5 fixes single node sparsemem support. In the case
> when multiple nodes are used, setup_memory() in arch/i386/mm/discontig.c calls
> get_memcfg_numa() which calls memory_present(). The single node case with
> setup_memory() in arch/i386/kernel/setup.c does not call memory_present()
> without this patch, which breaks single node support.

First of all, this is really a feature addition, not a bug fix. :)

The reason we haven't included this so far is that we don't really have
any machines that need sparsemem on i386 that aren't NUMA.  So, we
disabled it for now, and probably need to decide first why we need it
before a patch like that goes in.

I actually have exactly the same patch that you sent out in my tree, but
it's just for testing.  Magnus, perhaps we can get some of my testing
patches in good enough shape to put them in -mm so that the non-NUMA
folks can do more sparsemem testing.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
