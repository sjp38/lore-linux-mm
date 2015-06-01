Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id CCAB26B0038
	for <linux-mm@kvack.org>; Mon,  1 Jun 2015 17:11:11 -0400 (EDT)
Received: by pacux9 with SMTP id ux9so77255137pac.3
        for <linux-mm@kvack.org>; Mon, 01 Jun 2015 14:11:11 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id qm2si23176633pac.57.2015.06.01.14.11.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jun 2015 14:11:10 -0700 (PDT)
Date: Mon, 1 Jun 2015 14:11:09 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [next:master 7235/7555] mm/page_alloc.c:654:121: warning:
 comparison of distinct pointer types lacks a cast
Message-Id: <20150601141109.19f65bd0f4e667783fa5ca7c@linux-foundation.org>
In-Reply-To: <20150531121815.254f9bc2@BR9TG4T3.de.ibm.com>
References: <201505300112.mcr8MSyM%fengguang.wu@intel.com>
	<20150529133252.b0fa852381a501ff9df2ffdc@linux-foundation.org>
	<20150531121815.254f9bc2@BR9TG4T3.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dominik Dingel <dingel@linux.vnet.ibm.com>
Cc: kbuild test robot <fengguang.wu@intel.com>, kbuild-all@01.org, Linux Memory Management List <linux-mm@kvack.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Sun, 31 May 2015 12:18:15 +0200 Dominik Dingel <dingel@linux.vnet.ibm.com> wrote:

> > And on s390, HPAGE_SHIFT is unsigned int.  On x86 HPAGE_SHIFT has type
> > int.  I suggest the fix here is to make s390's HPAGE_SHIFT have type
> > int as well.
> 
> Thanks for noticing. As my way to handle this was mostly inspired by the
> way powerpc does it,  I'm kind of puzzled why they don't have the same problem?
> 
> So I checked and your fix seems to be the right thing to do. But then I would
> assume the powerpc type for HPAGE should also be changed?

powerpc sets CONFIG_HUGETLB_PAGE_SIZE_VARIABLE so it uses

extern int pageblock_order;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
