Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j87ISf5p018595
	for <linux-mm@kvack.org>; Wed, 7 Sep 2005 14:28:41 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j87ISfgh030746
	for <linux-mm@kvack.org>; Wed, 7 Sep 2005 14:28:41 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j87ISeet020787
	for <linux-mm@kvack.org>; Wed, 7 Sep 2005 14:28:40 -0400
Subject: Re: [PATCH] i386: single node SPARSEMEM fix
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <512850000.1126117362@flay>
References: <20050906035531.31603.46449.sendpatchset@cherry.local>
	 <1126114116.7329.16.camel@localhost>  <512850000.1126117362@flay>
Content-Type: text/plain
Date: Wed, 07 Sep 2005 11:27:54 -0700
Message-Id: <1126117674.7329.27.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@mbligh.org>
Cc: Magnus Damm <magnus@valinux.co.jp>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "A. P. Whitcroft [imap]" <andyw@uk.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2005-09-07 at 11:22 -0700, Martin J. Bligh wrote:
> CONFIG_NUMA was meant to (and did at one point) support both NUMA and flat
> machines. This is essential in order for the distros to support it - same
> will go for sparsemem.

That's a different issue.  The current code works if you boot a NUMA=y
SPARSEMEM=y machine with a single node.  The current Kconfig options
also enforce that SPARSEMEM depends on NUMA on i386.

Magnus would like to enable SPARSEMEM=y while CONFIG_NUMA=n.  That
requires some Kconfig changes, as well as an extra memory present call.
I'm questioning why we need to do that when we could never do
DISCONTIG=y while NUMA=n on i386.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
