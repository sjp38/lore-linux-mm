Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 956C26B0253
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 19:16:56 -0500 (EST)
Received: by padhx2 with SMTP id hx2so60692311pad.1
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 16:16:56 -0800 (PST)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id sf2si7796506pbc.162.2015.11.18.16.16.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Nov 2015 16:16:55 -0800 (PST)
Received: by pacdm15 with SMTP id dm15so60700707pac.3
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 16:16:55 -0800 (PST)
Subject: Re: [PATCH v3 4/4] x86: mm: support ARCH_MMAP_RND_BITS.
References: <1447888808-31571-1-git-send-email-dcashman@android.com>
 <1447888808-31571-2-git-send-email-dcashman@android.com>
 <1447888808-31571-3-git-send-email-dcashman@android.com>
 <1447888808-31571-4-git-send-email-dcashman@android.com>
 <1447888808-31571-5-git-send-email-dcashman@android.com>
From: Daniel Cashman <dcashman@android.com>
Message-ID: <564D14F5.4070407@android.com>
Date: Wed, 18 Nov 2015 16:16:53 -0800
MIME-Version: 1.0
In-Reply-To: <1447888808-31571-5-git-send-email-dcashman@android.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux@arm.linux.org.uk, akpm@linux-foundation.org, keescook@chromium.org, mingo@kernel.org, linux-arm-kernel@lists.infradead.org, corbet@lwn.net, dzickus@redhat.com, ebiederm@xmission.com, xypron.glpk@gmx.de, jpoimboe@redhat.com, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, mgorman@suse.de, tglx@linutronix.de, rientjes@google.com, linux-mm@kvack.org, linux-doc@vger.kernel.org, salyzyn@android.com, jeffv@google.com, nnk@google.com, catalin.marinas@arm.com, will.deacon@arm.com, hpa@zytor.com, x86@kernel.org, hecmargi@upv.es, bp@suse.de, dcashman@google.com

On 11/18/2015 03:20 PM, Daniel Cashman wrote:

> -	/*
> -	 *  8 bits of randomness in 32bit mmaps, 20 address space bits
> -	 * 28 bits of randomness in 64bit mmaps, 40 address space bits
> -	 */

This should be removed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
