Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 04AEB6B0038
	for <linux-mm@kvack.org>; Mon, 23 Nov 2015 13:55:20 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so199428045pac.3
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 10:55:19 -0800 (PST)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id xz3si21816582pbc.52.2015.11.23.10.55.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Nov 2015 10:55:19 -0800 (PST)
Received: by pabfh17 with SMTP id fh17so205361693pab.0
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 10:55:19 -0800 (PST)
Subject: Re: [PATCH v3 3/4] arm64: mm: support ARCH_MMAP_RND_BITS.
References: <1447888808-31571-1-git-send-email-dcashman@android.com>
 <1447888808-31571-2-git-send-email-dcashman@android.com>
 <1447888808-31571-3-git-send-email-dcashman@android.com>
 <1447888808-31571-4-git-send-email-dcashman@android.com>
 <20151123150459.GD4236@arm.com>
From: Daniel Cashman <dcashman@android.com>
Message-ID: <56536114.1020305@android.com>
Date: Mon, 23 Nov 2015 10:55:16 -0800
MIME-Version: 1.0
In-Reply-To: <20151123150459.GD4236@arm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: linux-kernel@vger.kernel.org, linux@arm.linux.org.uk, akpm@linux-foundation.org, keescook@chromium.org, mingo@kernel.org, linux-arm-kernel@lists.infradead.org, corbet@lwn.net, dzickus@redhat.com, ebiederm@xmission.com, xypron.glpk@gmx.de, jpoimboe@redhat.com, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, mgorman@suse.de, tglx@linutronix.de, rientjes@google.com, linux-mm@kvack.org, linux-doc@vger.kernel.org, salyzyn@android.com, jeffv@google.com, nnk@google.com, catalin.marinas@arm.com, hpa@zytor.com, x86@kernel.org, hecmargi@upv.es, bp@suse.de, dcashman@google.com

On 11/23/2015 07:04 AM, Will Deacon wrote:
> On Wed, Nov 18, 2015 at 03:20:07PM -0800, Daniel Cashman wrote:
>> +config ARCH_MMAP_RND_BITS_MAX
>> +       default 20 if ARM64_64K_PAGES && ARCH_VA_BITS=39
>> +       default 24 if ARCH_VA_BITS=39
>> +       default 23 if ARM64_64K_PAGES && ARCH_VA_BITS=42
>> +       default 27 if ARCH_VA_BITS=42
>> +       default 29 if ARM64_64K_PAGES && ARCH_VA_BITS=48
>> +       default 33 if ARCH_VA_BITS=48
>> +       default 15 if ARM64_64K_PAGES
>> +       default 19
>> +
>> +config ARCH_MMAP_RND_COMPAT_BITS_MIN
>> +       default 7 if ARM64_64K_PAGES
>> +       default 11
> 
> FYI: we now support 16k pages too, so this might need updating. It would
> be much nicer if this was somehow computed rather than have the results
> all open-coded like this.

Yes, I ideally wanted this to be calculated based on the different page
options and VA_BITS (which itself has a similar stanza), but I don't
know how to do that/if it is currently supported in Kconfig. This would
be even more desirable with the addition of 16K_PAGES, as with this
setup we have a combinatorial problem.

We could move this logic into the code where min/max are initialized,
but that would create its own mess, creating new Kconfig values to
introduce it in an arch-agnostic way after patch-set v2 moved that to
mm/mmap.c instread of arch/${arch}/mm/mmap.c Suggestions welcome.

Thank You,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
