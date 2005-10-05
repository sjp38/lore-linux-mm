Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j95GbpeV028560
	for <linux-mm@kvack.org>; Wed, 5 Oct 2005 12:37:51 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j95Gbot2088436
	for <linux-mm@kvack.org>; Wed, 5 Oct 2005 12:37:50 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j95GboW9025066
	for <linux-mm@kvack.org>; Wed, 5 Oct 2005 12:37:50 -0400
Subject: Re: [PATCH] i386: srat and numaq cleanup
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20051005083846.4308.37575.sendpatchset@cherry.local>
References: <20051005083846.4308.37575.sendpatchset@cherry.local>
Content-Type: text/plain
Date: Wed, 05 Oct 2005 09:37:42 -0700
Message-Id: <1128530262.26009.27.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Magnus Damm <magnus@valinux.co.jp>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2005-10-05 at 17:39 +0900, Magnus Damm wrote:
> Cleanup the i386 NUMA code by creating inline no-op functions for
> get_memcfg_numaq/srat() and get_zholes_size_numaq/srat().

>  arch/i386/kernel/srat.c   |   10 ++++++++--
>  include/asm-i386/mmzone.h |   26 +++++++++++++++++---------
>  include/asm-i386/numaq.h  |   10 ++++++++--
>  include/asm-i386/srat.h   |   15 ++++++++++-----
>  4 files changed, 43 insertions(+), 18 deletions(-)

I'm highly suspicious of any "cleanup" that adds more code than it
deletes.  What does this clean up?

This patch is a little bit confused.  It makes the
get_zholes_size_srat() always safe to call at runtime.  However, it
still creates a compile-time stub version of it as well.  

In addition, you already have the srat.c-local zholes_size_init, but you
still add the has_srat variable.  Seems a bit superfluous.

Calling get_zholes_size_numaq() at runtime is unnecessary.  The NUMA-Q
is not supported with the ARCH_GENERIC code.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
