Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f72.google.com (mail-lf1-f72.google.com [209.85.167.72])
	by kanga.kvack.org (Postfix) with ESMTP id 59FBB8E00F9
	for <linux-mm@kvack.org>; Sat,  5 Jan 2019 12:53:53 -0500 (EST)
Received: by mail-lf1-f72.google.com with SMTP id l6so402897lfk.19
        for <linux-mm@kvack.org>; Sat, 05 Jan 2019 09:53:53 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a9sor15417529lfg.18.2019.01.05.09.53.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 05 Jan 2019 09:53:51 -0800 (PST)
From: Uladzislau Rezki <urezki@gmail.com>
Date: Sat, 5 Jan 2019 18:53:31 +0100
Subject: Re: [RFC PATCH 3/3] selftests/vm: add script helper for
 CONFIG_TEST_VMALLOC_MODULE
Message-ID: <20190105175331.hogka35k3qkweewo@pc636>
References: <20190103142108.20744-1-urezki@gmail.com>
 <20190103142108.20744-4-urezki@gmail.com>
 <d62089c4-8225-6363-1de5-ff2e8a3f684e@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d62089c4-8225-6363-1de5-ff2e8a3f684e@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: shuah <shuah@kernel.org>
Cc: "Uladzislau Rezki (Sony)" <urezki@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Kees Cook <keescook@chromium.org>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>, Thomas Gleixner <tglx@linutronix.de>

On Fri, Jan 04, 2019 at 11:34:30AM -0700, shuah wrote:
> On 1/3/19 7:21 AM, Uladzislau Rezki (Sony) wrote:
> > Add the test script for the kernel test driver to analyse vmalloc
> > allocator for benchmarking and stressing purposes. It is just a kernel
> > module loader. You can specify and pass different parameters in order
> > to investigate allocations behaviour. See "usage" output for more
> > details.
> > 
> > Also add basic vmalloc smoke test to the "run_vmtests" suite.
> > 
> > Signed-off-by: Uladzislau Rezki (Sony) <urezki@gmail.com>
> > ---
> 
> Thanks for adding skip handling. Here is my
> 
> Reviewed-by: Shuah Khan <shuah@kernel.org>
> 
Thanks Shuah!

--
Vlad Rezki
