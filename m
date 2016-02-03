Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id CE5FF828F6
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 16:28:02 -0500 (EST)
Received: by mail-qg0-f45.google.com with SMTP id y9so21530737qgd.3
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 13:28:02 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id l14si7250437qhl.37.2016.02.03.13.28.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Feb 2016 13:28:02 -0800 (PST)
Date: Wed, 3 Feb 2016 13:28:00 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [linux-next:master 2619/2735] fs/dax.c:988:42: error: implicit
 declaration of function '__dax_dbg'
Message-Id: <20160203132800.b0811df604334a3364812be5@linux-foundation.org>
In-Reply-To: <201602031647.zWSCV1Gh%fengguang.wu@intel.com>
References: <201602031647.zWSCV1Gh%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Matthew Wilcox <willy@linux.intel.com>, kbuild-all@01.org, Linux Memory Management List <linux-mm@kvack.org>, Stephen Rothwell <sfr@canb.auug.org.au>

On Wed, 3 Feb 2016 16:26:49 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:

> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> head:   8babd99a86f51315697523470924eeb7435b9c34
> commit: c1da6853b50923e8e400acefcdc51c558d5cc02e [2619/2735] dax: support for transparent PUD pages
> config: x86_64-randconfig-s4-02031530 (attached as .config)
> reproduce:
>         git checkout c1da6853b50923e8e400acefcdc51c558d5cc02e
>         # save the attached .config to linux build tree
>         make ARCH=x86_64 
> 
> All error/warnings (new ones prefixed by >>):
> 
>    fs/dax.c: In function 'dax_pud_fault':
> >> fs/dax.c:988:42: error: implicit declaration of function '__dax_dbg' [-Werror=implicit-function-declaration]
>     #define dax_pud_dbg(bh, address, reason) __dax_dbg(bh, address, reason, "dax_pud")

These patches are being a problem.  I'll disable

mm-convert-an-open-coded-vm_bug_on_vma.patch
mmfsdax-change-pmd_fault-to-huge_fault.patch
mmfsdax-change-pmd_fault-to-huge_fault-fix.patch
mm-add-support-for-pud-sized-transparent-hugepages.patch
mm-add-support-for-pud-sized-transparent-hugepages-fix.patch
mm-add-support-for-pud-sized-transparent-hugepages-fix-2.patch
procfs-add-support-for-puds-to-smaps-clear_refs-and-pagemap.patch
x86-add-support-for-pud-sized-transparent-hugepages.patch
x86-add-support-for-pud-sized-transparent-hugepages-fix.patch
x86-add-support-for-pud-sized-transparent-hugepages-checkpatch-fixes.patch
dax-support-for-transparent-pud-pages.patch
ext4-support-for-pud-sized-transparent-huge-pages.patch

and shall do another mmotm in a couple of hours.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
