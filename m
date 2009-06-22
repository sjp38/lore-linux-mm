Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id BBA286B004F
	for <linux-mm@kvack.org>; Mon, 22 Jun 2009 05:54:18 -0400 (EDT)
Subject: Re: [PATCH] kmemleak: use pr_fmt
From: Catalin Marinas <catalin.marinas@arm.com>
In-Reply-To: <1245440992.6201.17.camel@Joe-Laptop>
References: <1245341337.29927.8.camel@Joe-Laptop.home>
	 <1245405220.12653.25.camel@pc1117.cambridge.arm.com>
	 <1245440992.6201.17.camel@Joe-Laptop>
Content-Type: text/plain
Date: Mon, 22 Jun 2009 10:55:52 +0100
Message-Id: <1245664552.15580.36.camel@pc1117.cambridge.arm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Joe Perches <joe@perches.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2009-06-19 at 12:49 -0700, Joe Perches wrote:
> On Fri, 2009-06-19 at 10:53 +0100, Catalin Marinas wrote:
> > Thanks for the patch. It missed one pr_info case (actually invoked via
> > the pr_helper macro).
> 
> This change will affect the seq_printf uses.
> Some think the seq output should be immutable.
> Perhaps that's important to you or others.

My point was that with your patch, the kmemleak kernel messages with
pr_info were something like:

kmemleak: kmemleak: unreferenced object ...
kmemleak:   comm ...
kmemleak:   backtrace:

After dropping "kmemleak: " in the print_helper() call, kernel messages
become (which I find nicer):

kmemleak: unreferenced object ...
kmemleak:   comm ...
kmemleak:   backtrace:

For the seq_printf() we really don't need the "kmemleak: " prefix since
you read a kmemleak-specific file anyway. With my modification, the seq
output becomes:

unreferenced object ...
  comm ...
  backtrace:

i.e. without the "kmemleak: " prefix on the "unreferenced ..." line.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
