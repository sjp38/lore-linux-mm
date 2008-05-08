Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m48Iglcb013758
	for <linux-mm@kvack.org>; Thu, 8 May 2008 14:42:47 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m48Iglvw277316
	for <linux-mm@kvack.org>; Thu, 8 May 2008 14:42:47 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m48Igk1J009668
	for <linux-mm@kvack.org>; Thu, 8 May 2008 14:42:47 -0400
Subject: Re: [PATCH] x86: fix PAE pmd_bad bootup warning
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20080508171657.GO23990@us.ibm.com>
References: <Pine.LNX.4.64.0805062043580.11647@blonde.site>
	 <20080506202201.GB12654@escobedo.amd.com>
	 <1210106579.4747.51.camel@nimitz.home.sr71.net>
	 <20080508143453.GE12654@escobedo.amd.com>
	 <1210258350.7905.45.camel@nimitz.home.sr71.net>
	 <20080508151145.GG12654@escobedo.amd.com>
	 <1210261882.7905.49.camel@nimitz.home.sr71.net>
	 <20080508161925.GH12654@escobedo.amd.com>
	 <20080508163352.GN23990@us.ibm.com>
	 <20080508165111.GI12654@escobedo.amd.com>
	 <20080508171657.GO23990@us.ibm.com>
Content-Type: text/plain
Date: Thu, 08 May 2008 11:42:44 -0700
Message-Id: <1210272164.7905.66.camel@nimitz.home.sr71.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Hans Rosenfeld <hans.rosenfeld@amd.com>, Hugh Dickins <hugh@veritas.com>, Ingo Molnar <mingo@elte.hu>, Jeff Chua <jeff.chua.linux@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Gabriel C <nix.or.die@googlemail.com>, Arjan van de Ven <arjan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2008-05-08 at 10:16 -0700, Nishanth Aravamudan wrote:
> 
> Dunno, seems quite clear that the bug is in pagemap_read(), not any
> hugepage code, and that the simplest fix is to make pagemap_read() do
> what the other walker-callers do, and skip hugepage regions.

Agreed, this certainly isn't a huge page bug.

But, I do think it is absolutely insane to have pmd_clear_bad() going
after perfectly good hugetlb pmds.  The way it is set up now, people are
bound to miss the hugetlb pages because just about every single
pagetable walk has to be specially coded to handle or avoid them.  We
obviously missed it, here, and we had two good examples in the same
file! :)

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
