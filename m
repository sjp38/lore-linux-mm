Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m48K5MmR002257
	for <linux-mm@kvack.org>; Thu, 8 May 2008 16:05:22 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m48K8KFS186324
	for <linux-mm@kvack.org>; Thu, 8 May 2008 14:08:20 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m48K8JDv029474
	for <linux-mm@kvack.org>; Thu, 8 May 2008 14:08:20 -0600
Subject: Re: [PATCH] x86: fix PAE pmd_bad bootup warning
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <1210276153.7018.90.camel@calx>
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
	 <Pine.LNX.4.64.0805081914210.16611@blonde.site>
	 <1210276153.7018.90.camel@calx>
Content-Type: text/plain
Date: Thu, 08 May 2008 13:08:17 -0700
Message-Id: <1210277297.7905.74.camel@nimitz.home.sr71.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: Hugh Dickins <hugh@veritas.com>, Nishanth Aravamudan <nacc@us.ibm.com>, Hans Rosenfeld <hans.rosenfeld@amd.com>, Ingo Molnar <mingo@elte.hu>, Jeff Chua <jeff.chua.linux@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Gabriel C <nix.or.die@googlemail.com>, Arjan van de Ven <arjan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2008-05-08 at 14:49 -0500, Matt Mackall wrote:
> I'd gone to some lengths to pull VMAs out of the picture as it's quite
> ugly to have to simultaneously walk VMAs and pagetables. But I may have
> to concede that living with hugepages requires it.

Yeah, it will definitely change the way that we have to do the pagetable
walk.

Should we just pass the mm around and make anyone that really wants to
get the VMAs do the lookup themselves?  Or, should we just provide the
VMA?

I'll start with just the mm and see where it goes...

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
