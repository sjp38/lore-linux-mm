Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e35.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id j95GHpgG030353
	for <linux-mm@kvack.org>; Wed, 5 Oct 2005 12:17:51 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j95GKYfK547560
	for <linux-mm@kvack.org>; Wed, 5 Oct 2005 10:20:34 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j95GKYej031892
	for <linux-mm@kvack.org>; Wed, 5 Oct 2005 10:20:34 -0600
Subject: Re: sparsemem & sparsemem extreme question
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20051005161009.GA10146@osiris.ibm.com>
References: <20051004065030.GA21741@osiris.boeblingen.de.ibm.com>
	 <1128442502.20208.6.camel@localhost>
	 <20051005063909.GA9699@osiris.boeblingen.de.ibm.com>
	 <1128527554.26009.2.camel@localhost>
	 <20051005155823.GA10119@osiris.ibm.com>
	 <1128528340.26009.8.camel@localhost>
	 <20051005161009.GA10146@osiris.ibm.com>
Content-Type: text/plain
Date: Wed, 05 Oct 2005 09:20:22 -0700
Message-Id: <1128529222.26009.16.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2005-10-05 at 18:10 +0200, Heiko Carstens wrote:
> > > No, my concern is actually that the s390 archticture actually will come up
> > > with some sort of memory that's present in the physical address space where
> > > the most significant bit of the addresses will be turned _on_.
> > 
> > Why do you think this?
> 
> That's a matter of fact and what the Specs say...

I'd appreciate any pointer to the relevant information, especially the
stuff that explains just how sparse a physical address space can be on
that architecture.  What would discontigmem have done with the same
layout?  Does s390 even support discontigmem?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
