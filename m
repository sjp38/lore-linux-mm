Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1864E6B304C
	for <linux-mm@kvack.org>; Fri, 24 Aug 2018 11:23:52 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id 20-v6so7833879ois.21
        for <linux-mm@kvack.org>; Fri, 24 Aug 2018 08:23:52 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id m126-v6si5175483oib.322.2018.08.24.08.23.50
        for <linux-mm@kvack.org>;
        Fri, 24 Aug 2018 08:23:50 -0700 (PDT)
Date: Fri, 24 Aug 2018 16:23:46 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH] kmemleak: Always register debugfs file
Message-ID: <20180824152345.hebdwpatberaah3a@armageddon.cambridge.arm.com>
References: <20180824131220.19176-1-vincent.whitchurch@axis.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180824131220.19176-1-vincent.whitchurch@axis.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vincent Whitchurch <vincent.whitchurch@axis.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vincent Whitchurch <rabinv@axis.com>

On Fri, Aug 24, 2018 at 03:12:20PM +0200, Vincent Whitchurch wrote:
> If kmemleak built in to the kernel, but is disabled by default, the
> debugfs file is never registered.  Because of this, it is not possible
> to find out if the kernel is built with kmemleak support by checking for
> the presence of this file.  To allow this, always register the file.
> 
> After this patch, if the file doesn't exist, kmemleak is not available
> in the kernel.  If writing "scan" or any other value than "clear" to
> this file results in EBUSY, then kmemleak is available but is disabled
> by default and can be activated via the kernel command line.
> 
> Signed-off-by: Vincent Whitchurch <vincent.whitchurch@axis.com>

I think that's also consistent with a late disabling of kmemleak when
the debugfs entry sticks around.

Acked-by: Catalin Marinas <catalin.marinas@arm.com>
