Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m09JSn0q014277
	for <linux-mm@kvack.org>; Wed, 9 Jan 2008 14:28:49 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m09JSnH6489518
	for <linux-mm@kvack.org>; Wed, 9 Jan 2008 14:28:49 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m09JSmw5003801
	for <linux-mm@kvack.org>; Wed, 9 Jan 2008 14:28:49 -0500
Subject: Re: [PATCH 10/10] x86: Unify percpu.h
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20080108211025.293924000@sgi.com>
References: <20080108211023.923047000@sgi.com>
	 <20080108211025.293924000@sgi.com>
Content-Type: text/plain
Date: Wed, 09 Jan 2008 11:28:24 -0800
Message-Id: <1199906905.9834.101.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: travis@sgi.com
Cc: Andrew Morton <akpm@linux-foundation.org>, mingo@elte.hu, Andi Kleen <ak@suse.de>, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>, tglx@linutronix.de, mingo@redhat.com
List-ID: <linux-mm.kvack.org>

On Tue, 2008-01-08 at 13:10 -0800, travis@sgi.com wrote:
> Form a single percpu.h from percpu_32.h and percpu_64.h. Both are now pretty
> small so this is simply adding them together. 

I guess I just don't really see the point of moving the code around like
this.  Before, it would have been easier to tell at a glance before
whether you were looking at 32 or 64-bit code because of which file you
are in.  But, now, you need to look for #ifdef context.  I'm not sure
that's a win.

This only saves 5 net lines of code, and those are probably from:

-#ifndef __ARCH_I386_PERCPU__
-#define __ARCH_I386_PERCPU__

right?

The rest of the set looks brilliant, though.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
