Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate4.de.ibm.com (8.12.10/8.12.10) with ESMTP id j95GB5O0201440
	for <linux-mm@kvack.org>; Wed, 5 Oct 2005 16:11:05 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j95GB5vk164370
	for <linux-mm@kvack.org>; Wed, 5 Oct 2005 18:11:05 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11/8.13.3) with ESMTP id j95GB5GW003358
	for <linux-mm@kvack.org>; Wed, 5 Oct 2005 18:11:05 +0200
Date: Wed, 5 Oct 2005 18:10:09 +0200
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: sparsemem & sparsemem extreme question
Message-ID: <20051005161009.GA10146@osiris.ibm.com>
References: <20051004065030.GA21741@osiris.boeblingen.de.ibm.com> <1128442502.20208.6.camel@localhost> <20051005063909.GA9699@osiris.boeblingen.de.ibm.com> <1128527554.26009.2.camel@localhost> <20051005155823.GA10119@osiris.ibm.com> <1128528340.26009.8.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1128528340.26009.8.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> > No, my concern is actually that the s390 archticture actually will come up
> > with some sort of memory that's present in the physical address space where
> > the most significant bit of the addresses will be turned _on_.
> 
> Why do you think this?

That's a matter of fact and what the Specs say...

Heiko

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
