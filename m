Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j34NT6ua039034
	for <linux-mm@kvack.org>; Mon, 4 Apr 2005 19:29:06 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j34NT67c191792
	for <linux-mm@kvack.org>; Mon, 4 Apr 2005 17:29:06 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id j34NT6hL032345
	for <linux-mm@kvack.org>; Mon, 4 Apr 2005 17:29:06 -0600
Subject: Re: [PATCH 1/4] create mm/Kconfig for arch-independent memory
	options
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20050404232254.GC6500@w-mikek2.ibm.com>
References: <E1DIViE-0006Kf-00@kernel.beaverton.ibm.com>
	 <20050404232254.GC6500@w-mikek2.ibm.com>
Content-Type: text/plain
Date: Mon, 04 Apr 2005 16:29:02 -0700
Message-Id: <1112657342.27328.64.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Kravetz <kravetz@us.ibm.com>
Cc: Andrew Morton <akpm@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2005-04-04 at 16:22 -0700, Mike Kravetz wrote:
> Do you need to set ARCH_DISCONTIGMEM_DEFAULT instead of just
> CONFIG_ARCH_DISCONTIGMEM_ENABLE to have DISCONTIGMEM be the
> default? or am I missing something?  I don't see
> ARCH_DISCONTIGMEM_DEFAULT turned on by default in any of these
> patches.

It's a wee bit confusing, but I think it all works out.

Doing ARCH_DISCONTIGMEM_ENABLE=y turns off the FLATMEM option in the
mm/Kconfig prompt because FLATMEM depends on !ARCH_DISCONTIGMEM_ENABLE.
So, if you enable it, it will end up being the default because there's
no other choice.

For configs that *need* both options, you can re-enable FLATMEM with
ARCH_FLATMEM_ENABLE

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
