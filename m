Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m46Kh2ov017985
	for <linux-mm@kvack.org>; Tue, 6 May 2008 16:43:02 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m46Kh2wk212194
	for <linux-mm@kvack.org>; Tue, 6 May 2008 14:43:02 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m46Kh1BQ001168
	for <linux-mm@kvack.org>; Tue, 6 May 2008 14:43:02 -0600
Subject: Re: [PATCH] x86: fix PAE pmd_bad bootup warning
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20080506202201.GB12654@escobedo.amd.com>
References: <b6a2187b0805051806v25fa1272xb08e0b70b9c3408@mail.gmail.com>
	 <20080506124946.GA2146@elte.hu>
	 <Pine.LNX.4.64.0805061435510.32567@blonde.site>
	 <alpine.LFD.1.10.0805061138580.32269@woody.linux-foundation.org>
	 <Pine.LNX.4.64.0805062043580.11647@blonde.site>
	 <20080506202201.GB12654@escobedo.amd.com>
Content-Type: text/plain
Date: Tue, 06 May 2008 13:42:59 -0700
Message-Id: <1210106579.4747.51.camel@nimitz.home.sr71.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hans Rosenfeld <hans.rosenfeld@amd.com>
Cc: Hugh Dickins <hugh@veritas.com>, Ingo Molnar <mingo@elte.hu>, Jeff Chua <jeff.chua.linux@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Gabriel C <nix.or.die@googlemail.com>, Arjan van de Ven <arjan@linux.intel.com>, Nishanth Aravamudan <nacc@us.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2008-05-06 at 22:22 +0200, Hans Rosenfeld wrote:
> I expected that any hugepage that a process had mmapped would
> automatically be returned to the system when the process exits. That was
> not the case, the process exited and the hugepage was lost (unless I
> changed the program to explicitly munmap the hugepage before exiting).
> Removing the hugetlbfs file containing the hugepage also didn't free the
> page.

Could you post the code you're using to do this?  I have to wonder if
you're leaving a fd open somewhere.  Even if you rm the hugepage file,
it'll stay allocated if you have a fd open, or if *someone* is still
mapping it. 

Can you umount your hugetlbfs?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
