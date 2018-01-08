Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 294E86B029F
	for <linux-mm@kvack.org>; Mon,  8 Jan 2018 11:14:40 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id k2so7219857wrh.16
        for <linux-mm@kvack.org>; Mon, 08 Jan 2018 08:14:40 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f19sor3142394wmf.65.2018.01.08.08.14.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 08 Jan 2018 08:14:38 -0800 (PST)
Date: Mon, 8 Jan 2018 17:14:35 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH v4] selftest/vm: Move the 128 TB mmap boundary test to the
 generic VM directory
Message-ID: <20180108161435.e3jjrttk57lib63a@gmail.com>
References: <20171123165226.32582-1-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171123165226.32582-1-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H . Peter Anvin" <hpa@zytor.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


* Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com> wrote:

> Architectures like ppc64 do support mmap hint addr based large address space
> selection. This test can be run on those architectures too. Move the test to
> selftest/vm so that other archs can use the same.
> 
> We also add a few new test scenarios in this patch. We do test few boundary
> condition before we do a high address mmap. ppc64 use the addr limit to validate
> addr in the fault path. We had bugs in this area w.r.t slb fault handling
> before we updated the addr limit.
> 
> We also touch the allocated space to make sure we don't have any bugs in the
> fault handling path.
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> ---
> Changes from V2:
> * Rebase on top of -tip tree.
> * update the correct license
> * use memset to touch the full mmap range.
> 
>  tools/testing/selftests/vm/Makefile         |   1 +
>  tools/testing/selftests/vm/run_vmtests      |  11 ++
>  tools/testing/selftests/vm/va_128TBswitch.c | 297 ++++++++++++++++++++++++++++
>  tools/testing/selftests/x86/5lvl.c          | 177 -----------------
>  4 files changed, 309 insertions(+), 177 deletions(-)
>  create mode 100644 tools/testing/selftests/vm/va_128TBswitch.c
>  delete mode 100644 tools/testing/selftests/x86/5lvl.c

This will now apply (almost) cleanly to Linus's latest tree - I fixed up a trivial 
conflict in selftests/vm/Makefile.

Note that I also improved the changelog.

Note #2: I'd suggest this patch to be split into two patches:

 - patch 1 moves the testcase to vm/selftests
 - patch 2 does all the additional improvements

because this way all the deltas will be much easier to see and review.

Thanks,

	Ingo

=================>
