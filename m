Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 827036B13F1
	for <linux-mm@kvack.org>; Wed,  8 Feb 2012 09:45:38 -0500 (EST)
Date: Wed, 8 Feb 2012 08:45:35 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] selftests: Launch individual selftests from the main
 Makefile
In-Reply-To: <20120208034055.GA23894@somewhere.redhat.com>
Message-ID: <alpine.DEB.2.00.1202080843250.29839@router.home>
References: <20120205081555.GA2249@darkstar.redhat.com> <20120206155340.b9075240.akpm@linux-foundation.org> <20120208034055.GA23894@somewhere.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Frederic Weisbecker <fweisbec@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Young <dyoung@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, xiyou.wangcong@gmail.com, penberg@kernel.org, fengguang.wu@intel.com

Note that slub also has an embedded selftest (see function
resiliency_test). That code could be separated out and put with the
selftests that you are creating now.

I also have a series of in kernel benchmarks for the page allocation, vm
statistics and slab allocators that could be useful to included somewhere.

All this code runs in the kernel context.

For the in kernel benchmarks I am creating modules that fail to load but
first run the tests.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
