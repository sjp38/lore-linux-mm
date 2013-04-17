Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id AF2086B0081
	for <linux-mm@kvack.org>; Wed, 17 Apr 2013 05:56:16 -0400 (EDT)
In-Reply-To: <516D90F6.3020603@linux.intel.com>
Subject: Re: Re: [PATCH] futex: bugfix for futex-key conflict when futex use
 hugepage
MIME-Version: 1.0
Message-ID: <OF79A40956.94F46B9C-ON48257B50.00320F73-48257B50.0036925D@zte.com.cn>
From: zhang.yi20@zte.com.cn
Date: Wed, 17 Apr 2013 17:55:29 +0800
Content-Type: text/plain; charset="US-ASCII"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Darren Hart <dvhart@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>

Darren Hart <dvhart@linux.intel.com> wrote on 2013/04/17 01:57:10:

> Again, a functional testcase in futextest would be a good idea. This
> helps validate the patch and also can be used to identify regressions in
> the future.

I will post the testcase code later.

> 
> What is the max value of comp_idx? Are we at risk of truncating it?
> Looks like not really from my initial look.
> 
> This also needs a comment in futex.h describing the usage of the offset
> field in union futex_key as well as above get_futex_key describing the
> key for shared mappings.
> 
> 

As far as I know , the max size of one hugepage is 1 GBytes for x86 cpu.
Can some other cpus support greater hugepage even more than 4 GBytes? If 
so, we can change the type of 'offset' from int to long to avoid 
truncating.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
