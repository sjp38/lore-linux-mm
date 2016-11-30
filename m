Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id C68B56B0038
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 14:22:02 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id v84so375019420oie.0
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 11:22:02 -0800 (PST)
Received: from bh-25.webhostbox.net (bh-25.webhostbox.net. [208.91.199.152])
        by mx.google.com with ESMTPS id t40si31812620ota.70.2016.11.30.11.22.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 30 Nov 2016 11:22:01 -0800 (PST)
Date: Wed, 30 Nov 2016 11:21:59 -0800
From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: next: Commit 'mm: Prevent __alloc_pages_nodemask() RCU CPU stall
 ...' causing hang on sparc32 qemu
Message-ID: <20161130192159.GB22216@roeck-us.net>
References: <20161129212308.GA12447@roeck-us.net>
 <20161130012817.GH3924@linux.vnet.ibm.com>
 <b96c1560-3f06-bb6d-717a-7a0f0c6e869a@roeck-us.net>
 <20161130070212.GM3924@linux.vnet.ibm.com>
 <929f6b29-461a-6e94-fcfd-710c3da789e9@roeck-us.net>
 <20161130120333.GQ3924@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161130120333.GQ3924@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, sparclinux@vger.kernel.org, davem@davemloft.net

On Wed, Nov 30, 2016 at 04:03:33AM -0800, Paul E. McKenney wrote:
> On Wed, Nov 30, 2016 at 02:52:11AM -0800, Guenter Roeck wrote:
> > On 11/29/2016 11:02 PM, Paul E. McKenney wrote:
> > >On Tue, Nov 29, 2016 at 08:32:51PM -0800, Guenter Roeck wrote:
> > >>On 11/29/2016 05:28 PM, Paul E. McKenney wrote:
> > >>>On Tue, Nov 29, 2016 at 01:23:08PM -0800, Guenter Roeck wrote:
> > >>>>Hi Paul,
> > >>>>
> > >>>>most of my qemu tests for sparc32 targets started to fail in next-20161129.
> > >>>>The problem is only seen in SMP builds; non-SMP builds are fine.
> > >>>>Bisect points to commit 2d66cccd73436 ("mm: Prevent __alloc_pages_nodemask()
> > >>>>RCU CPU stall warnings"); reverting that commit fixes the problem.
> 
> And I have dropped this patch.  Michal Hocko showed me the error of
> my ways with this patch.
> 

:-)

On another note, I still get RCU tracebacks in the s390 tests.

BUG: sleeping function called from invalid context at mm/page_alloc.c:3775

That is caused by 'rcu: Maintain special bits at bottom of ->dynticks counter';
if I recall correctly we had discussed that earlier.

Thanks,
Guenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
