Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k7SKrNlf011447
	for <linux-mm@kvack.org>; Mon, 28 Aug 2006 16:53:23 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k7SKrN2x291352
	for <linux-mm@kvack.org>; Mon, 28 Aug 2006 16:53:23 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7SKrNkf001473
	for <linux-mm@kvack.org>; Mon, 28 Aug 2006 16:53:23 -0400
Subject: Re: [RFC][PATCH 1/7] generic PAGE_SIZE infrastructure (v2)
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <Pine.LNX.4.64.0608280954100.27677@schroedinger.engr.sgi.com>
References: <20060828154413.E05721BD@localhost.localdomain>
	 <Pine.LNX.4.64.0608280954100.27677@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Mon, 28 Aug 2006 13:53:17 -0700
Message-Id: <1156798397.5408.23.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2006-08-28 at 10:01 -0700, Christoph Lameter wrote:
> Note that there is a generic ALIGN macro in include/linux/kernel.h plus
> __ALIGNs in linux/linkage.h. Could you use that and get to some sane 
> conventin for all these ALIGN functions?

The one in kernel.h should certainly be consolidated.  What would you
think about a linux/macros.h that had things like ARRAY_SIZE and the
ALIGN macros, but didn't have any outside dependencies?  How about a
linux/align.h just for the alignment macros?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
