Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8006C6B0261
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 17:52:50 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id n14so3256091pfh.15
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 14:52:50 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id 39si597954plc.68.2017.11.01.14.52.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Nov 2017 14:52:49 -0700 (PDT)
Subject: Re: [PATCH 02/23] x86, kaiser: do not set _PAGE_USER for init_mm page
 tables
References: <20171031223146.6B47C861@viggo.jf.intel.com>
 <20171031223150.AB41C68F@viggo.jf.intel.com>
 <alpine.DEB.2.20.1711012206050.1942@nanos>
 <CALCETrWQ0W=Kp7fycZ2E9Dp84CCPOr1nEmsPom71ZAXeRYqr9g@mail.gmail.com>
 <alpine.DEB.2.20.1711012225400.1942@nanos>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <e8149c9e-10f8-aa74-ff0e-e2de923b2128@linux.intel.com>
Date: Wed, 1 Nov 2017 14:52:48 -0700
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1711012225400.1942@nanos>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Andy Lutomirski <luto@kernel.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, moritz.lipp@iaik.tugraz.at, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, michael.schwarz@iaik.tugraz.at, Linus Torvalds <torvalds@linux-foundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, X86 ML <x86@kernel.org>

On 11/01/2017 02:28 PM, Thomas Gleixner wrote:
> On Wed, 1 Nov 2017, Andy Lutomirski wrote:
>> The vsyscall page is _PAGE_USER and lives in init_mm via the fixmap.
> 
> Groan, forgot about that abomination, but still there is no point in having
> it marked PAGE_USER in the init_mm at all, kaiser or not.

So shouldn't this patch effectively make the vsyscall page unusable?
Any idea why that didn't show up in any of the x86 selftests?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
