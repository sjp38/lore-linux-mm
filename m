Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j2QJ0xGI022717
	for <linux-mm@kvack.org>; Sat, 26 Mar 2005 14:00:59 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j2QJ0wus250948
	for <linux-mm@kvack.org>; Sat, 26 Mar 2005 14:00:59 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11/8.12.11) with ESMTP id j2QJ0w1c019213
	for <linux-mm@kvack.org>; Sat, 26 Mar 2005 14:00:58 -0500
Subject: Re: [RFC][PATCH 1/4] create mm/Kconfig for arch-independent memory
	options
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <4244D068.3080900@osdl.org>
References: <E1DEwlP-0006BQ-00@kernel.beaverton.ibm.com>
	 <4244D068.3080900@osdl.org>
Content-Type: text/plain
Date: Sat, 26 Mar 2005 11:00:49 -0800
Message-Id: <1111863649.9691.100.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Randy.Dunlap" <rddunlap@osdl.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2005-03-25 at 19:00 -0800, Randy.Dunlap wrote:
...
> > +config DISCONTIGMEM
> > +	bool "Discontigious Memory"
> > +	depends on ARCH_DISCONTIGMEM_ENABLE
> > +	help
> > +	  If unsure, choose this option over "Sparse Memory".
> Same question....

It's in the third patch in the series.  They were all together at one
point and I was trying to be lazy, but you caught me :)

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
