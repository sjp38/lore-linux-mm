Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 8CD576B0005
	for <linux-mm@kvack.org>; Sun, 24 Feb 2013 17:10:35 -0500 (EST)
Date: Mon, 25 Feb 2013 09:10:13 +1100
From: paul.szabo@sydney.edu.au
Message-Id: <201302242210.r1OMADAd021416@como.maths.usyd.edu.au>
Subject: Re: [RFC] Reproducible OOM with just a few sleeps
In-Reply-To: <51209E9C.3020507@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave@linux.vnet.ibm.com, simon.jeons@gmail.com
Cc: 695182@bugs.debian.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Dear Simon,

> So if he config sparse memory, the issue can be solved I think.

In my config file I have:

CONFIG_HAVE_SPARSE_IRQ=y
CONFIG_SPARSE_IRQ=y
CONFIG_ARCH_SPARSEMEM_ENABLE=y
# CONFIG_SPARSEMEM_MANUAL is not set
CONFIG_SPARSEMEM_STATIC=y
# CONFIG_INPUT_SPARSEKMAP is not set
# CONFIG_SPARSE_RCU_POINTER is not set

Is that sufficient for sparse memory, or should I try something else?
Or maybe, you meant that some kernel source patches might be possible
in the sparse memory code?

Thanks, Paul

Paul Szabo   psz@maths.usyd.edu.au   http://www.maths.usyd.edu.au/u/psz/
School of Mathematics and Statistics   University of Sydney    Australia

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
