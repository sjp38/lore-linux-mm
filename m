Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate2.de.ibm.com (8.12.10/8.12.10) with ESMTP id j95Hkad7107336
	for <linux-mm@kvack.org>; Wed, 5 Oct 2005 17:46:36 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j95HkZvk163648
	for <linux-mm@kvack.org>; Wed, 5 Oct 2005 19:46:35 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11/8.13.3) with ESMTP id j95HkZHA008184
	for <linux-mm@kvack.org>; Wed, 5 Oct 2005 19:46:35 +0200
Date: Wed, 5 Oct 2005 19:45:42 +0200
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: sparsemem & sparsemem extreme question
Message-ID: <20051005174542.GB10204@osiris.ibm.com>
References: <20051004065030.GA21741@osiris.boeblingen.de.ibm.com> <1128442502.20208.6.camel@localhost> <20051005063909.GA9699@osiris.boeblingen.de.ibm.com> <1128527554.26009.2.camel@localhost> <20051005155823.GA10119@osiris.ibm.com> <1128528340.26009.8.camel@localhost> <20051005161009.GA10146@osiris.ibm.com> <1128529222.26009.16.camel@localhost> <20051005171230.GA10204@osiris.ibm.com> <1128532809.26009.39.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1128532809.26009.39.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> > Anything specific you need to know about the memory layout?
> How sparse is it?  How few present pages can be there be in a worst-case
> physical area?

Worst case that is already currently valid is that you can have 1 MB
segments whereever you want in address space.

For instance I just configured a virtual machine that has the following
memory layout:

Address Range
-----------------------------------
0000000000000000 - 00000000000FFFFF
000000FFC0000000 - 000000FFC00FFFFF

Even though it's currently not possible to define memory segments above
1TB, this limit is likely to go away.
In addition if running in a logical partition we always have a small gap
at the 2GB barrier. Not sure how large that gap is, I'll check tomorrow.

Heiko

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
