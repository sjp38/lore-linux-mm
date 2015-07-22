Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f172.google.com (mail-ie0-f172.google.com [209.85.223.172])
	by kanga.kvack.org (Postfix) with ESMTP id 74E2A6B0261
	for <linux-mm@kvack.org>; Tue, 21 Jul 2015 21:25:20 -0400 (EDT)
Received: by ietj16 with SMTP id j16so156348996iet.0
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 18:25:20 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id f4si47129173pdc.198.2015.07.21.18.25.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Jul 2015 18:25:19 -0700 (PDT)
Message-ID: <1437528316.16792.7.camel@ellerman.id.au>
Subject: Re: [PATCH V4 2/6] mm: mlock: Add new mlock, munlock, and
 munlockall system calls
From: Michael Ellerman <mpe@ellerman.id.au>
Date: Wed, 22 Jul 2015 11:25:16 +1000
In-Reply-To: <20150721134441.d69e4e1099bd43e56835b3c5@linux-foundation.org>
References: <1437508781-28655-1-git-send-email-emunson@akamai.com>
	 <1437508781-28655-3-git-send-email-emunson@akamai.com>
	 <20150721134441.d69e4e1099bd43e56835b3c5@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Eric B Munson <emunson@akamai.com>, linux-mips@linux-mips.org, linux-m68k@vger.kernel.org, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, Stephen Rothwell <sfr@canb.auug.org.au>, linux-am33-list@redhat.com, Geert Uytterhoeven <geert@linux-m68k.org>, Vlastimil Babka <vbabka@suse.cz>, Guenter Roeck <linux@roeck-us.net>, linux-xtensa@linux-xtensa.org, linux-s390@vger.kernel.org, adi-buildroot-devel@lists.sourceforge.net, linux-arm-kernel@lists.infradead.org, linux-cris-kernel@axis.com, linux-parisc@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On Tue, 2015-07-21 at 13:44 -0700, Andrew Morton wrote:
> On Tue, 21 Jul 2015 15:59:37 -0400 Eric B Munson <emunson@akamai.com> wrote:
> 
> > With the refactored mlock code, introduce new system calls for mlock,
> > munlock, and munlockall.  The new calls will allow the user to specify
> > what lock states are being added or cleared.  mlock2 and munlock2 are
> > trivial at the moment, but a follow on patch will add a new mlock state
> > making them useful.
> > 
> > munlock2 addresses a limitation of the current implementation.  If a
> > user calls mlockall(MCL_CURRENT | MCL_FUTURE) and then later decides
> > that MCL_FUTURE should be removed, they would have to call munlockall()
> > followed by mlockall(MCL_CURRENT) which could potentially be very
> > expensive.  The new munlockall2 system call allows a user to simply
> > clear the MCL_FUTURE flag.
> 
> This is hard.  Maybe we shouldn't have wired up anything other than
> x86.  That's what we usually do with new syscalls.

Yeah I think so.

You haven't wired it up properly on powerpc, but I haven't mentioned it because
I'd rather we did it.

cheers


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
