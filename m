Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id iBDMGkDr571326
	for <linux-mm@kvack.org>; Mon, 13 Dec 2004 17:16:46 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id iBDMGjXP212550
	for <linux-mm@kvack.org>; Mon, 13 Dec 2004 15:16:46 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id iBDMGjI3022223
	for <linux-mm@kvack.org>; Mon, 13 Dec 2004 15:16:45 -0700
Date: Mon, 13 Dec 2004 14:16:19 -0800
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: Anticipatory prefaulting in the page fault handler V1
Message-ID: <8880000.1102976179@flay>
In-Reply-To: <Pine.LNX.4.58.0412130905140.360@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.44.0411221457240.2970-100000@localhost.localdomain><156610000.1102546207@flay> <Pine.LNX.4.58.0412091130160.796@schroedinger.engr.sgi.com><200412132330.23893.amgta@yacht.ocn.ne.jp> <Pine.LNX.4.58.0412130905140.360@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>, Akinobu Mita <amgta@yacht.ocn.ne.jp>
Cc: nickpiggin@yahoo.com.au, Jeff Garzik <jgarzik@pobox.com>, torvalds@osdl.org, hugh@veritas.com, benh@kernel.crashing.org, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

>> I also encountered processes segfault.
>> Below patch fix several problems.
>> 
>> 1) if no pages could allocated, returns VM_FAULT_OOM
>> 2) fix duplicated pte_offset_map() call
> 
> I also saw these two issues and I think I dealt with them in a forthcoming
> patch.
> 
>> 3) don't set_pte() for the entry which already have been set
> 
> Not sure how this could have happened in the patch.
> 
> Could you try my updated version:

Urgle. There was a fix from Hugh too ... any chance you could just stick
a whole new patch somewhere? I'm too idle/stupid to work it out ;-)

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
