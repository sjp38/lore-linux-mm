Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j2QL8Rsf012640
	for <linux-mm@kvack.org>; Sat, 26 Mar 2005 16:08:27 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j2QL8RC5089204
	for <linux-mm@kvack.org>; Sat, 26 Mar 2005 16:08:27 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.12.11) with ESMTP id j2QL8RUj017100
	for <linux-mm@kvack.org>; Sat, 26 Mar 2005 16:08:27 -0500
Subject: Re: [RFC][PATCH 1/4] create mm/Kconfig for arch-independent memory
	options
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <4245CC80.10306@osdl.org>
References: <E1DEwlP-0006BQ-00@kernel.beaverton.ibm.com>
	 <4244D068.3080900@osdl.org> <1111863649.9691.100.camel@localhost>
	 <4245CC80.10306@osdl.org>
Content-Type: text/plain
Date: Sat, 26 Mar 2005 13:08:23 -0800
Message-Id: <1111871303.9691.110.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Randy.Dunlap" <rddunlap@osdl.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Sat, 2005-03-26 at 12:56 -0800, Randy.Dunlap wrote:
> I wasn't trying to catch you, but I've already looked at
> all 4 patches in the series and I still can't find an
> option that is labeled/described as "Sparse Memory"....
> The word "sparse" isn't even in patch 3/4... maybe
> there is something missing?

Nope, you're not missing anything.  I'm just a little mixed up.  You can
find the actual "Sparse Memory" option in this patch:

http://sr71.net/patches/2.6.12/2.6.12-rc1-mhp2/broken-out/B-sparse-151-add-to-mm-Kconfig.patch

I could easily remove the references to it in the patches that I posted
RFC, but I hoped that they would get in quickly enough that it wouldn't
matter.  Also, the help option does say that all of the options probably
won't show up.  So, users shouldn't be horribly confused if they don't
see the sparsemem option.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
