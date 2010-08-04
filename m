Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2206C62012A
	for <linux-mm@kvack.org>; Wed,  4 Aug 2010 04:59:53 -0400 (EDT)
Date: Wed, 4 Aug 2010 16:59:48 +0800
From: Yong Zhang <yong.zhang@windriver.com>
Subject: Re: question about CONFIG_BASE_SMALL
Message-ID: <20100804085948.GA21549@windriver.com>
Reply-To: Yong Zhang <yong.zhang@windriver.com>
References: <AANLkTi=1DxqLrqVbfRouOBRWg4RHFaHz438X7F1JWL6P@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <AANLkTi=1DxqLrqVbfRouOBRWg4RHFaHz438X7F1JWL6P@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Ryan Wang <openspace.wang@gmail.com>
Cc: kernelnewbies@nl.linux.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 04, 2010 at 04:38:12PM +0800, Ryan Wang wrote:
> Hi all,
> 
>       I noticed CONFIG_BASE_SMALL in different parts
> of the kernel code, with ifdef/ifndef.
>       I wonder what does CONFIG_BASE_SMALL mean?
> And how can I configure it, e.g. through make menuconfig?

Yeah, here:

init/Kconfig:
...
config BASE_SMALL
	int
	default 0 if BASE_FULL
	default 1 if !BASE_FULL
...
config BASE_FULL
	default y
	bool "Enable full-sized data structures for core" if EMBEDDED
	help
	  Disabling this option reduces the size of miscellaneous core
	  kernel data structures. This saves memory on small machines,

> 
> thanks,
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
