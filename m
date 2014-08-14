Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 052DA6B0036
	for <linux-mm@kvack.org>; Thu, 14 Aug 2014 11:02:27 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id et14so1774333pad.37
        for <linux-mm@kvack.org>; Thu, 14 Aug 2014 08:02:27 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id dh3si4481354pdb.125.2014.08.14.08.02.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Aug 2014 08:02:26 -0700 (PDT)
Message-ID: <53ECCF7E.2090305@infradead.org>
Date: Thu, 14 Aug 2014 08:02:22 -0700
From: Randy Dunlap <rdunlap@infradead.org>
MIME-Version: 1.0
Subject: Re: linux-next: Tree for Aug 14 (mm/memory_hotplug.c and drivers/base/memory.c)
References: <20140814152749.24d43663@canb.auug.org.au>
In-Reply-To: <20140814152749.24d43663@canb.auug.org.au>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>, linux-next@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

On 08/13/14 22:27, Stephen Rothwell wrote:
> Hi all,
> 
> Please do not add code intended for v3.18 until after v3.17-rc1 is
> released.
> 
> Changes since 20140813:
> 

on x86_64:

drivers/built-in.o: In function `show_zones_online_to':
memory.c:(.text+0x13f306): undefined reference to `test_pages_in_a_zone'

in drivers/base/memory.c

when CONFIG_MEMORY_HOTREMOVE is not enabled.

The function implementation in mm/memory_hotplug.c is only built if
CONFIG_MEMORY_HOTREMOVE is enabled.


-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
