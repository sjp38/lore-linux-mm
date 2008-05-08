Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m48J6tXl007823
	for <linux-mm@kvack.org>; Thu, 8 May 2008 15:06:55 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m48J6t9x267426
	for <linux-mm@kvack.org>; Thu, 8 May 2008 15:06:55 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m48J6sG0020812
	for <linux-mm@kvack.org>; Thu, 8 May 2008 15:06:55 -0400
Subject: Re: [PATCH] x86: fix PAE pmd_bad bootup warning
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <Pine.LNX.4.64.0805081951570.21297@blonde.site>
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
	 <1210272164.7905.66.camel@nimitz.home.sr71.net>
	 <Pine.LNX.4.64.0805081951570.21297@blonde.site>
Content-Type: text/plain
Date: Thu, 08 May 2008 12:06:53 -0700
Message-Id: <1210273613.7905.69.camel@nimitz.home.sr71.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, Hans Rosenfeld <hans.rosenfeld@amd.com>, Ingo Molnar <mingo@elte.hu>, Jeff Chua <jeff.chua.linux@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Gabriel C <nix.or.die@googlemail.com>, Arjan van de Ven <arjan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2008-05-08 at 19:58 +0100, Hugh Dickins wrote:
> But it's
> simply wrong for a "generic" pagewalker to be going blindly in there.
> 
> Two good examples in the same file??

I was just noting that the other two pagewalking users did the right
vm_huge..() check, and we missed it in the third pagewalker user.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
