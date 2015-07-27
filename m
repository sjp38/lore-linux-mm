Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id A8DE86B0038
	for <linux-mm@kvack.org>; Mon, 27 Jul 2015 02:43:05 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so101806672wib.1
        for <linux-mm@kvack.org>; Sun, 26 Jul 2015 23:43:05 -0700 (PDT)
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com. [209.85.212.169])
        by mx.google.com with ESMTPS id eu16si26330153wjd.43.2015.07.26.23.43.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 26 Jul 2015 23:43:04 -0700 (PDT)
Received: by wibxm9 with SMTP id xm9so101805939wib.1
        for <linux-mm@kvack.org>; Sun, 26 Jul 2015 23:43:03 -0700 (PDT)
Date: Mon, 27 Jul 2015 09:43:00 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH V5 2/7] mm: mlock: Add new mlock system call
Message-ID: <20150727064300.GB11657@node.dhcp.inet.fi>
References: <1437773325-8623-1-git-send-email-emunson@akamai.com>
 <1437773325-8623-3-git-send-email-emunson@akamai.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1437773325-8623-3-git-send-email-emunson@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, Heiko Carstens <heiko.carstens@de.ibm.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Catalin Marinas <catalin.marinas@arm.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Guenter Roeck <linux@roeck-us.net>, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, adi-buildroot-devel@lists.sourceforge.net, linux-cris-kernel@axis.com, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-am33-list@redhat.com, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

On Fri, Jul 24, 2015 at 05:28:40PM -0400, Eric B Munson wrote:
> With the refactored mlock code, introduce a new system call for mlock.
> The new call will allow the user to specify what lock states are being
> added.  mlock2 is trivial at the moment, but a follow on patch will add
> a new mlock state making it useful.
> 
> Signed-off-by: Eric B Munson <emunson@akamai.com>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
> Cc: Geert Uytterhoeven <geert@linux-m68k.org>
> Cc: Catalin Marinas <catalin.marinas@arm.com>
> Cc: Stephen Rothwell <sfr@canb.auug.org.au>
> Cc: Guenter Roeck <linux@roeck-us.net>
> Cc: linux-alpha@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> Cc: linux-arm-kernel@lists.infradead.org
> Cc: adi-buildroot-devel@lists.sourceforge.net
> Cc: linux-cris-kernel@axis.com
> Cc: linux-ia64@vger.kernel.org
> Cc: linux-m68k@lists.linux-m68k.org
> Cc: linux-am33-list@redhat.com
> Cc: linux-parisc@vger.kernel.org
> Cc: linuxppc-dev@lists.ozlabs.org
> Cc: linux-s390@vger.kernel.org
> Cc: linux-sh@vger.kernel.org
> Cc: sparclinux@vger.kernel.org
> Cc: linux-xtensa@linux-xtensa.org
> Cc: linux-api@vger.kernel.org
> Cc: linux-arch@vger.kernel.org
> Cc: linux-mm@kvack.org
> ---
> Changes from V4:
> * Drop all architectures except x86[_64] from this patch, MIPS is added
>   later in the series.  All others will be left to their maintainers.
> 
> Changes from V3:
> * Do a (hopefully) complete job of adding the new system calls
>  arch/alpha/include/uapi/asm/mman.h     | 2 ++
>  arch/mips/include/uapi/asm/mman.h      | 5 +++++
>  arch/parisc/include/uapi/asm/mman.h    | 2 ++
>  arch/powerpc/include/uapi/asm/mman.h   | 2 ++
>  arch/sparc/include/uapi/asm/mman.h     | 2 ++
>  arch/tile/include/uapi/asm/mman.h      | 5 +++++
>  arch/x86/entry/syscalls/syscall_32.tbl | 1 +
>  arch/x86/entry/syscalls/syscall_64.tbl | 1 +
>  arch/xtensa/include/uapi/asm/mman.h    | 5 +++++

Define MLOCK_LOCKED in include/uapi/asm-generic/mman-common.h.
This way you can drop changes in powerpc, sparc and tile.

Otherwise looks good.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
