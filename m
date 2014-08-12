Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id 36AF66B0035
	for <linux-mm@kvack.org>; Tue, 12 Aug 2014 18:03:07 -0400 (EDT)
Received: by mail-ig0-f171.google.com with SMTP id l13so8279665iga.16
        for <linux-mm@kvack.org>; Tue, 12 Aug 2014 15:03:07 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id f13si514623igt.24.2014.08.12.15.03.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Aug 2014 15:03:06 -0700 (PDT)
Date: Tue, 12 Aug 2014 15:03:04 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/1] memblock, memhotplug: Fix wrong type in
 memblock_find_in_range_node().
Message-Id: <20140812150304.74a7da3f2491f3d8f8a30107@linux-foundation.org>
In-Reply-To: <1407651123-10994-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1407651123-10994-1-git-send-email-tangchen@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: santosh.shilimkar@ti.com, grygorii.strashko@ti.com, phacht@linux.vnet.ibm.com, yinghai@kernel.org, fabf@skynet.be, Emilian.Medve@freescale.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, 10 Aug 2014 14:12:03 +0800 Tang Chen <tangchen@cn.fujitsu.com> wrote:

> In memblock_find_in_range_node(), we defeind ret as int. But it shoule
> be phys_addr_t because it is used to store the return value from
> __memblock_find_range_bottom_up().
> 
> The bug has not been triggered because when allocating low memory near
> the kernel end, the "int ret" won't turn out to be minus. When we started
> to allocate memory on other nodes, and the "int ret" could be minus.
> Then the kernel will panic.
> 
> A simple way to reproduce this: comment out the following code in numa_init(),
> 
>         memblock_set_bottom_up(false);
> 
> and the kernel won't boot.

Which kernel versions need this fix?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
