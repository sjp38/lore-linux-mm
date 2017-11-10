Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 66B2A280298
	for <linux-mm@kvack.org>; Fri, 10 Nov 2017 07:57:57 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id w95so4974824wrc.20
        for <linux-mm@kvack.org>; Fri, 10 Nov 2017 04:57:57 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n23sor3884940wra.41.2017.11.10.04.57.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 10 Nov 2017 04:57:56 -0800 (PST)
Date: Fri, 10 Nov 2017 13:57:53 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 08/30] x86, kaiser: unmap kernel from userspace page
 tables (core patch)
Message-ID: <20171110125752.qd2ui2fwwc5c35ea@gmail.com>
References: <20171108194646.907A1942@viggo.jf.intel.com>
 <20171108194701.7632448F@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171108194701.7632448F@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, richard.fellner@student.tugraz.at, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org


* Dave Hansen <dave.hansen@linux.intel.com> wrote:

> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> These patches are based on work from a team at Graz University of
> Technology: https://github.com/IAIK/KAISER .  This work would not have
> been possible without their work as a starting point.

> Note: The original KAISER authors signed-off on their patch.  Some of
> their code has been broken out into other patches in this series, but
> their SoB was only retained here.
> 
> Signed-off-by: Richard Fellner <richard.fellner@student.tugraz.at>
> Signed-off-by: Moritz Lipp <moritz.lipp@iaik.tugraz.at>
> Signed-off-by: Daniel Gruss <daniel.gruss@iaik.tugraz.at>
> Signed-off-by: Michael Schwarz <michael.schwarz@iaik.tugraz.at>
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>

That's not how SOB chains should be used normally - nor does the current code have 
much resemblance to the original code.

So you credit them in the file:

> --- /dev/null	2017-11-06 07:51:38.702108459 -0800
> +++ b/arch/x86/mm/kaiser.c	2017-11-08 10:45:29.893681394 -0800
> @@ -0,0 +1,412 @@
> +/*
> + * Copyright(c) 2017 Intel Corporation. All rights reserved.
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of version 2 of the GNU General Public License as
> + * published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope that it will be useful, but
> + * WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
> + * General Public License for more details.
> + *
> + * Based on work published here: https://github.com/IAIK/KAISER
> + * Modified by Dave Hansen <dave.hansen@intel.com to actually work.

You could credit the original authors via something like:

	/*
	 * The original KAISER patch, on which this code is based in part, was 
	 * written by and signed off by for the Linux kernel by:
	 *
	 *   Signed-off-by: Richard Fellner <richard.fellner@student.tugraz.at>
	 *   Signed-off-by: Moritz Lipp <moritz.lipp@iaik.tugraz.at>
         *   Signed-off-by: Daniel Gruss <daniel.gruss@iaik.tugraz.at>
	 *   Signed-off-by: Michael Schwarz <michael.schwarz@iaik.tugraz.at>
	 *
	 * At:
	 *
	 *   https://github.com/IAIK/KAISER
	 */

Or something like that - but the original SOBs should not be carried over as-is 
into the commit log entry.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
