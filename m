Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 2087F6B00A6
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 14:43:12 -0500 (EST)
Received: by fg-out-1718.google.com with SMTP id 19so504896fgg.4
        for <linux-mm@kvack.org>; Tue, 17 Feb 2009 11:43:10 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20090217181157.GA2158@cmpxchg.org>
References: <20090123154653.GA14517@wotan.suse.de>
	 <200902041748.41801.nickpiggin@yahoo.com.au>
	 <20090204152709.GA4799@csn.ul.ie>
	 <200902051459.30064.nickpiggin@yahoo.com.au>
	 <20090216184200.GA31264@csn.ul.ie> <4999BBE6.2080003@cs.helsinki.fi>
	 <alpine.DEB.1.10.0902171120040.27813@qirst.com>
	 <1234890096.11511.6.camel@penberg-laptop>
	 <alpine.DEB.1.10.0902171204070.15929@qirst.com>
	 <20090217181157.GA2158@cmpxchg.org>
Date: Tue, 17 Feb 2009 21:43:10 +0200
Message-ID: <84144f020902171143i5844ef83h20cb4bee4f65c904@mail.gmail.com>
Subject: Re: [patch] SLQB slab allocator (try 2)
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <nickpiggin@yahoo.com.au>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Lin Ming <ming.m.lin@intel.com>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
List-ID: <linux-mm.kvack.org>

On Tue, Feb 17, 2009 at 12:05:07PM -0500, Christoph Lameter wrote:
>> Index: linux-2.6/include/linux/slub_def.h
>> ===================================================================
>> --- linux-2.6.orig/include/linux/slub_def.h   2009-02-17 10:45:51.000000000 -0600
>> +++ linux-2.6/include/linux/slub_def.h        2009-02-17 11:06:53.000000000 -0600
>> @@ -121,10 +121,21 @@
>>  #define KMALLOC_SHIFT_LOW ilog2(KMALLOC_MIN_SIZE)
>>
>>  /*
>> + * Maximum kmalloc object size handled by SLUB. Larger object allocations
>> + * are passed through to the page allocator. The page allocator "fastpath"
>> + * is relatively slow so we need this value sufficiently high so that
>> + * performance critical objects are allocated through the SLUB fastpath.
>> + *
>> + * This should be dropped to PAGE_SIZE / 2 once the page allocator
>> + * "fastpath" becomes competitive with the slab allocator fastpaths.
>> + */
>> +#define SLUB_MAX_SIZE (2 * PAGE_SIZE)

On Tue, Feb 17, 2009 at 8:11 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> This relies on PAGE_SIZE being 4k.  If you want 8k, why don't you say
> so?  Pekka did this explicitely.

That could be a problem, sure. Especially for architecture that have 64 K pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
