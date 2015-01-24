Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f171.google.com (mail-ob0-f171.google.com [209.85.214.171])
	by kanga.kvack.org (Postfix) with ESMTP id AB45F6B0032
	for <linux-mm@kvack.org>; Sat, 24 Jan 2015 02:03:55 -0500 (EST)
Received: by mail-ob0-f171.google.com with SMTP id va2so1250706obc.2
        for <linux-mm@kvack.org>; Fri, 23 Jan 2015 23:03:55 -0800 (PST)
Received: from bh-25.webhostbox.net (bh-25.webhostbox.net. [208.91.199.152])
        by mx.google.com with ESMTPS id x192si1900926oix.89.2015.01.23.23.03.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 23 Jan 2015 23:03:54 -0800 (PST)
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YEul5-000OQ0-UD
	for linux-mm@kvack.org; Sat, 24 Jan 2015 07:03:52 +0000
Date: Fri, 23 Jan 2015 23:03:41 -0800
From: Guenter Roeck <linux@roeck-us.net>
Subject: mmotm 2015-01-23-16-19: build failures due to 'mm/page_alloc.c:
 don't offset memmap for flatmem'
Message-ID: <20150124070341.GA30638@roeck-us.net>
References: <54c2e51c.VbfIg4TfoWD0Qi0z%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54c2e51c.VbfIg4TfoWD0Qi0z%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, Laura Abbott <lauraa@codeaurora.org>

On Fri, Jan 23, 2015 at 04:19:40PM -0800, akpm@linux-foundation.org wrote:
> The mm-of-the-moment snapshot 2015-01-23-16-19 has been uploaded to
> 
>    http://www.ozlabs.org/~akpm/mmotm/
> 
New build failure:

mm/page_alloc.c: In function 'alloc_node_mem_map':
mm/page_alloc.c:4973: error: 'ARCH_PFN_OFFSET' undeclared (first use in this
function)
mm/page_alloc.c:4973: error: (Each undeclared identifier is reported only once
mm/page_alloc.c:4973: error: for each function it appears in.)
make[1]: *** [mm/page_alloc.o] Error 1

Culprit is c2ae2ed329 ("mm/page_alloc.c: don't offset memmap for flatmem").
While the code in question was already there, it is now also built if
CONFIG_FLATMEM is defined. Since the file defining ARCH_PFN_OFFSET
is not directly included, the build now fails for some architectures.

Affected:
	avr32:defconfig
	avr32:merisc_defconfig
	avr32:atngw100mkii_evklcd101_defconfig
	m68k:m5272c3_defconfig
	m68k:m5307c3_defconfig
	m68k:m5249evb_defconfig
	m68k:m5407c3_defconfig
	mn10300:asb2303_defconfig
	mn10300:asb2364_defconfig

Guenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
