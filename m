Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 730B96B6873
	for <linux-mm@kvack.org>; Mon,  3 Sep 2018 11:02:35 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id v4-v6so695797oix.2
        for <linux-mm@kvack.org>; Mon, 03 Sep 2018 08:02:35 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id b5-v6si11519065oic.185.2018.09.03.08.02.34
        for <linux-mm@kvack.org>;
        Mon, 03 Sep 2018 08:02:34 -0700 (PDT)
Date: Mon, 3 Sep 2018 16:02:30 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH v3] kmemleak: add module param to print warnings to dmesg
Message-ID: <20180903150229.zwyc7nrjpacnwag3@armageddon.cambridge.arm.com>
References: <20180903144046.21023-1-vincent.whitchurch@axis.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180903144046.21023-1-vincent.whitchurch@axis.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vincent Whitchurch <vincent.whitchurch@axis.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vincent Whitchurch <rabinv@axis.com>

On Mon, Sep 03, 2018 at 04:40:46PM +0200, Vincent Whitchurch wrote:
> Currently, kmemleak only prints the number of suspected leaks to dmesg
> but requires the user to read a debugfs file to get the actual stack
> traces of the objects' allocation points.  Add a module option to print
> the full object information to dmesg too.  It can be enabled with
> kmemleak.verbose=1 on the kernel command line, or "echo 1 >
> /sys/module/kmemleak/parameters/verbose":
> 
> This allows easier integration of kmemleak into test systems:  We have
> automated test infrastructure to test our Linux systems.  With this
> option, running our tests with kmemleak is as simple as enabling
> kmemleak and passing this command line option; the test infrastructure
> knows how to save kernel logs, which will now include kmemleak reports.
> Without this option, the test infrastructure needs to be specifically
> taught to read out the kmemleak debugfs file.  Removing this need for
> special handling makes kmemleak more similar to other kernel debug
> options (slab debugging, debug objects, etc).
> 
> Signed-off-by: Vincent Whitchurch <vincent.whitchurch@axis.com>
> ---
> v3: Expand use case description.  Replace config option with module parameter.
> 
>  mm/kmemleak.c | 42 +++++++++++++++++++++++++++++++++++-------
>  1 file changed, 35 insertions(+), 7 deletions(-)

Acked-by: Catalin Marinas <catalin.marinas@arm.com>
