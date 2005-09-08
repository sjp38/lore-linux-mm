Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j88HivDC310532
	for <linux-mm@kvack.org>; Thu, 8 Sep 2005 13:44:57 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j88HjDui524200
	for <linux-mm@kvack.org>; Thu, 8 Sep 2005 11:45:14 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j88HipQK006489
	for <linux-mm@kvack.org>; Thu, 8 Sep 2005 11:44:51 -0600
Subject: Re: [PATCH] i386: single node SPARSEMEM fix
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20050907164945.14aba736.akpm@osdl.org>
References: <20050906035531.31603.46449.sendpatchset@cherry.local>
	 <1126114116.7329.16.camel@localhost> <512850000.1126117362@flay>
	 <1126117674.7329.27.camel@localhost> <521510000.1126118091@flay>
	 <20050907164945.14aba736.akpm@osdl.org>
Content-Type: text/plain
Date: Wed, 07 Sep 2005 17:46:34 -0700
Message-Id: <1126140395.6354.14.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: "Martin J. Bligh" <mbligh@mbligh.org>, magnus@valinux.co.jp, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "A. P. Whitcroft [imap]" <andyw@uk.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2005-09-07 at 16:49 -0700, Andrew Morton wrote:
> "Martin J. Bligh" <mbligh@mbligh.org> wrote:
> > Ah, OK - makes more sense. However, some machines do have large holes
> > in e820 map setups - is not really critical, more of an efficiency
> > thing.
> 
> Confused.   Does all this mean that we want the patch, or not?

I say we wait on it.

Martin brings up a scenario in which SPARSEMEM is useful without NUMA,
but it Magnus's patch doesn't actually deal with systems like that.
Let's do it right, and base the memory_present() calls off of real data
from the e820 or efi data.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
