Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 031596B0005
	for <linux-mm@kvack.org>; Wed, 17 Feb 2016 17:53:56 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id fl4so18885116pad.0
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 14:53:55 -0800 (PST)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id 66si4749777pfs.142.2016.02.17.14.53.55
        for <linux-mm@kvack.org>;
        Wed, 17 Feb 2016 14:53:55 -0800 (PST)
Subject: Re: [PATCH 33/33] x86, pkeys: execute-only support
References: <20160212210152.9CAD15B0@viggo.jf.intel.com>
 <20160212210240.CB4BB5CA@viggo.jf.intel.com>
 <CAGXu5j+L6W17wkKNdheUQQ01bJE4ZXLDiG=5JBaNWju2j9NB2Q@mail.gmail.com>
 <CALCETrVUifty6QuXo67zt9DuxsgUPTqzFbaKGS0qXd75jAb35Q@mail.gmail.com>
From: Dave Hansen <dave@sr71.net>
Message-ID: <56C4FA01.2070008@sr71.net>
Date: Wed, 17 Feb 2016 14:53:53 -0800
MIME-Version: 1.0
In-Reply-To: <CALCETrVUifty6QuXo67zt9DuxsgUPTqzFbaKGS0qXd75jAb35Q@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>, Kees Cook <keescook@google.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, X86 ML <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>

On 02/17/2016 02:17 PM, Andy Lutomirski wrote:
>> > Is there a way to detect this feature's availability without userspace
>> > having to set up a segv handler and attempting to read a
>> > PROT_EXEC-only region? (i.e. cpu flag for protection keys, or a way to
>> > check the protection to see if PROT_READ got added automatically,
>> > etc?)
>> >
> We could add an HWCAP.

I'll bite.  What's an HWCAP?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
