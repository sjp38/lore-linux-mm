Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f174.google.com (mail-yk0-f174.google.com [209.85.160.174])
	by kanga.kvack.org (Postfix) with ESMTP id CEF806B0031
	for <linux-mm@kvack.org>; Sun,  2 Feb 2014 04:50:18 -0500 (EST)
Received: by mail-yk0-f174.google.com with SMTP id 10so32855391ykt.5
        for <linux-mm@kvack.org>; Sun, 02 Feb 2014 01:50:18 -0800 (PST)
Received: from science.horizon.com (science.horizon.com. [71.41.210.146])
        by mx.google.com with SMTP id n38si14046245yhp.173.2014.02.02.01.50.18
        for <linux-mm@kvack.org>;
        Sun, 02 Feb 2014 01:50:18 -0800 (PST)
Date: 2 Feb 2014 04:50:17 -0500
Message-ID: <20140202095017.32007.qmail@science.horizon.com>
From: "George Spelvin" <linux@horizon.com>
Subject: Re: [PATCH 3/3] Kconfig: organize memory-related config options
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave@sr71.net
Cc: linux@horizon.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

> +config MMAP_ALLOW_UNINITIALIZED
> +	bool "Allow mmapped anonymous memory to be uninitialized"
> +	depends on EXPERT && !MMU
> +	default n
> +	help
> +	  Normally, and according to the Linux spec, anonymous memory obtained
> +	  from mmap() has it's contents cleared before it is passed to
                          ^^^^

"its", please.

If you really want to make me happy, clarify the CONFIG_SLOB help to
explain what a large system is.  More than 4 CPUs?  More tha 32 GB
of RAM?  E-ATX motherboard?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
