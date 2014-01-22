Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 77ADB6B0035
	for <linux-mm@kvack.org>; Wed, 22 Jan 2014 15:41:10 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id kq14so900784pab.3
        for <linux-mm@kvack.org>; Wed, 22 Jan 2014 12:41:10 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id g6si1152535pad.227.2014.01.22.12.41.08
        for <linux-mm@kvack.org>;
        Wed, 22 Jan 2014 12:41:09 -0800 (PST)
Date: Wed, 22 Jan 2014 12:41:07 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH V5 2/3] mm/memblock: Add support for excluded memory
 areas
Message-Id: <20140122124107.ef0ceac16be17c165de56308@linux-foundation.org>
In-Reply-To: <20140122121821.6da53a02@lilie>
References: <1390217559-14691-1-git-send-email-phacht@linux.vnet.ibm.com>
	<1390217559-14691-3-git-send-email-phacht@linux.vnet.ibm.com>
	<20140122121821.6da53a02@lilie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Philipp Hachtmann <phacht@linux.vnet.ibm.com>
Cc: hannes@cmpxchg.org, liuj97@gmail.com, santosh.shilimkar@ti.com, grygorii.strashko@ti.com, iamjoonsoo.kim@lge.com, robin.m.holt@gmail.com, tangchen@cn.fujitsu.com, yinghai@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 22 Jan 2014 12:18:21 +0100 Philipp Hachtmann <phacht@linux.vnet.ibm.com> wrote:

> Hi again,
> 
> I'd like to remind that the s390 development relies on this patch
> (and the next one, for cleanliness, of course) being added. It would be
> very good to see it being added to the -mm tree resp. linux-next.
> 

Once the patch has passed review (hopefully by yinghai, who reviews
very well) I'd ask you to include it in the s390 tree which actually
uses it.

Patch 2/3 would benefit from a more complete changelog.  Why does s390
need CONFIG_ARCH_MEMBLOCK_NOMAP?  How is it used and how does it work? 
Do we expect other architectures to use it?  If so, how?  etcetera.

btw, you have a "#ifdef ARCH_MEMBLOCK_NOMAP" in there which should be
CONFIG_ARCH_MEMBLOCK_NOMAP.  I don't see how the code could have
compiled as-is - __next_mapped_mem_range() will be omitted?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
