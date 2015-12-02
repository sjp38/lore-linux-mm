Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f179.google.com (mail-qk0-f179.google.com [209.85.220.179])
	by kanga.kvack.org (Postfix) with ESMTP id E67F76B0253
	for <linux-mm@kvack.org>; Wed,  2 Dec 2015 08:53:29 -0500 (EST)
Received: by qkao63 with SMTP id o63so16074253qka.2
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 05:53:29 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h8si3522916qgd.114.2015.12.02.05.53.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Dec 2015 05:53:29 -0800 (PST)
Date: Wed, 2 Dec 2015 08:53:27 -0500
From: Aristeu Rozanski <aris@redhat.com>
Subject: Re: [PATCH 0/5] dump_stack: allow specifying printk log level
Message-ID: <20151202135327.GF29556@redhat.com>
References: <20151105223014.701269769@redhat.com>
 <20151109162125.GI8916@dhcp22.suse.cz>
 <20151201154820.abd9f2aba7a973daf29d2527@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151201154820.abd9f2aba7a973daf29d2527@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, linux-kerne@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>

On Tue, Dec 01, 2015 at 03:48:20PM -0800, Andrew Morton wrote:
> Seems reasonable to me as well and yes, there will be extra fill-in
> work to do.

I have some of the archs already converted, will wait until this initial
patchset is in to submit.

> The "lvl" thing stands out - kernel code doesn't do this arbitrary
> vowelicide to make identifiers shorter.  s/lvl/level/g?

There are show_regs_log_lvl(), show_trace_log_lvl(),
show_stack_log_lvl() (avr32, x86) and I just wanted to keep the naming
consistent. If you're strong about this I can change it and resubmit.

-- 
Aristeu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
