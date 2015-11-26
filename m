Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 930DD6B0254
	for <linux-mm@kvack.org>; Thu, 26 Nov 2015 02:08:00 -0500 (EST)
Received: by padhx2 with SMTP id hx2so82027790pad.1
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 23:08:00 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id we6si39657745pab.216.2015.11.25.23.07.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Nov 2015 23:07:59 -0800 (PST)
Message-ID: <1448521677.19291.3.camel@ellerman.id.au>
Subject: Re: [PATCH v3 0/4] Allow customizable random offset to mmap_base
 address.
From: Michael Ellerman <mpe@ellerman.id.au>
Date: Thu, 26 Nov 2015 18:07:57 +1100
In-Reply-To: <20151124163907.1a406b79458b1bb0d3519684@linux-foundation.org>
References: <1447888808-31571-1-git-send-email-dcashman@android.com>
	 <20151124163907.1a406b79458b1bb0d3519684@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Daniel Cashman <dcashman@android.com>
Cc: linux-kernel@vger.kernel.org, linux@arm.linux.org.uk, keescook@chromium.org, mingo@kernel.org, linux-arm-kernel@lists.infradead.org, corbet@lwn.net, dzickus@redhat.com, ebiederm@xmission.com, xypron.glpk@gmx.de, jpoimboe@redhat.com, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, mgorman@suse.de, tglx@linutronix.de, rientjes@google.com, linux-mm@kvack.org, linux-doc@vger.kernel.org, salyzyn@android.com, jeffv@google.com, nnk@google.com, catalin.marinas@arm.com, will.deacon@arm.com, hpa@zytor.com, x86@kernel.org, hecmargi@upv.es, bp@suse.de, dcashman@google.com, Ralf Baechle <ralf@linux-mips.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Tue, 2015-11-24 at 16:39 -0800, Andrew Morton wrote:
> On Wed, 18 Nov 2015 15:20:04 -0800 Daniel Cashman <dcashman@android.com> wrote:
> > Address Space Layout Randomization (ASLR) provides a barrier to
> > exploitation of user-space processes in the presence of security
> > vulnerabilities by making it more difficult to find desired code/data
> > which could help an attack.  This is done by adding a random offset to the
> > location of regions in the process address space, with a greater range of
> > potential offset values corresponding to better protection/a larger
> > search-space for brute force, but also to greater potential for
> > fragmentation.
> 
> mips, powerpc and s390 also implement arch_mmap_rnd().  Are there any
> special considerations here, or it just a matter of maintainers wiring
> it up and testing it?

I had a quick stab at powerpc. It seems to work OK, though I've only tested on
64-bit 64K pages.

I'll update this when Daniel does a version which supports a DEFAULT for both
MIN values.

cheers
