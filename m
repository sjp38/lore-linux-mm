Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 8CD6B6B002C
	for <linux-mm@kvack.org>; Wed,  8 Feb 2012 10:38:07 -0500 (EST)
Received: by ghrr18 with SMTP id r18so356321ghr.14
        for <linux-mm@kvack.org>; Wed, 08 Feb 2012 07:38:06 -0800 (PST)
Date: Wed, 8 Feb 2012 16:38:01 +0100
From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: Re: [PATCH] selftests: Launch individual selftests from the main
 Makefile
Message-ID: <20120208153759.GD25473@somewhere.redhat.com>
References: <20120205081555.GA2249@darkstar.redhat.com>
 <20120206155340.b9075240.akpm@linux-foundation.org>
 <20120208034055.GA23894@somewhere.redhat.com>
 <alpine.DEB.2.00.1202080843250.29839@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1202080843250.29839@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Young <dyoung@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, xiyou.wangcong@gmail.com, penberg@kernel.org, fengguang.wu@intel.com

On Wed, Feb 08, 2012 at 08:45:35AM -0600, Christoph Lameter wrote:
> Note that slub also has an embedded selftest (see function
> resiliency_test). That code could be separated out and put with the
> selftests that you are creating now.

That would be nice. As long as it's in userspace and it runs validation
tests, it's pretty welcome.

It's deemed to test expected behaviour with deterministic tests. stress tests
probably don't fit well there although it should be no problem if they are short.


> I also have a series of in kernel benchmarks for the page allocation, vm
> statistics and slab allocators that could be useful to included somewhere.
> 
> All this code runs in the kernel context.
> 
> For the in kernel benchmarks I am creating modules that fail to load but
> first run the tests.

Hmm, benchmarks tend to require some user analysis, I'm not sure if a batch of
validation tests is the right place for them. But loading modules is probably
not a problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
