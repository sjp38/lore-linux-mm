Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f180.google.com (mail-ea0-f180.google.com [209.85.215.180])
	by kanga.kvack.org (Postfix) with ESMTP id A84F76B0031
	for <linux-mm@kvack.org>; Thu, 16 Jan 2014 13:49:44 -0500 (EST)
Received: by mail-ea0-f180.google.com with SMTP id f15so1327509eak.11
        for <linux-mm@kvack.org>; Thu, 16 Jan 2014 10:49:44 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 3si3614363eeq.185.2014.01.16.10.49.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 16 Jan 2014 10:49:43 -0800 (PST)
Date: Thu, 16 Jan 2014 18:49:40 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [TLB range flush] +34.7% hackbench.throughput
Message-ID: <20140116184940.GR4963@suse.de>
References: <1389278098-27154-1-git-send-email-mgorman@suse.de>
 <20140116140118.GA22224@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20140116140118.GA22224@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Alex Shi <alex.shi@linaro.org>, Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, H Peter Anvin <hpa@zytor.com>, Linux-X86 <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jan 16, 2014 at 10:01:18PM +0800, Fengguang Wu wrote:
> Hi Mel,
> 
> I applied your patchset on v3.13-rc7 and get some test results. The
> results are encouraging: hackbench throughput increased by 34.7% with
> parameters 1600%-threads-pipe on a 2S SNB server.
> 
> In case you are interested, here are the full list of changes.
> kconfig is attached.
> 

I am intersted and thanks very much for the report. It's very encouraging.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
