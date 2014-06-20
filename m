Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 6F4096B0038
	for <linux-mm@kvack.org>; Fri, 20 Jun 2014 16:29:07 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id ey11so3458949pad.26
        for <linux-mm@kvack.org>; Fri, 20 Jun 2014 13:29:07 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id og8si11121939pbb.215.2014.06.20.13.29.06
        for <linux-mm@kvack.org>;
        Fri, 20 Jun 2014 13:29:06 -0700 (PDT)
Date: Fri, 20 Jun 2014 13:29:04 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [mmotm:master 188/230] fs/jffs2/debug.h:69:3: note: in
 expansion of macro 'pr_debug'
Message-Id: <20140620132904.ec7eced87ff449625ad10d78@linux-foundation.org>
In-Reply-To: <53a3e4f6.LlTrbyV58fY2TrZa%fengguang.wu@intel.com>
References: <53a3e4f6.LlTrbyV58fY2TrZa%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Yinghai Lu <yinghai@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

On Fri, 20 Jun 2014 15:38:30 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:

> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   df25ba7db0775d87018e2cd92f26b9b087093840
> commit: 0b3f61ac78013e35939696ddd63b9b871d11bf72 [188/230] initramfs: support initramfs that is more than 2G
> config: make ARCH=x86_64 allmodconfig
> 
> All warnings:

Too many :(  I dropped the patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
