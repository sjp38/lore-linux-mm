Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 9196F6B0098
	for <linux-mm@kvack.org>; Mon, 18 May 2015 04:34:40 -0400 (EDT)
Received: by wizk4 with SMTP id k4so69271004wiz.1
        for <linux-mm@kvack.org>; Mon, 18 May 2015 01:34:39 -0700 (PDT)
Received: from lb2-smtp-cloud6.xs4all.net (lb2-smtp-cloud6.xs4all.net. [194.109.24.28])
        by mx.google.com with ESMTPS id es2si11581610wib.12.2015.05.18.01.34.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 18 May 2015 01:34:39 -0700 (PDT)
Message-ID: <1431938073.2204.3.camel@x220>
Subject: Re: [PATCH v2 1/5] kasan, x86: move KASAN_SHADOW_OFFSET to the arch
 Kconfig
From: Paul Bolle <pebolle@tiscali.nl>
Date: Mon, 18 May 2015 10:34:33 +0200
In-Reply-To: <55599821.40409@samsung.com>
References: <1431698344-28054-1-git-send-email-a.ryabinin@samsung.com>
	 <1431698344-28054-2-git-send-email-a.ryabinin@samsung.com>
	 <1431775656.2341.10.camel@x220> <55599821.40409@samsung.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Alexander Potapenko <glider@google.com>, David Keitel <dkeitel@codeaurora.org>, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, "maintainer:X86
 ARCHITECTURE..." <x86@kernel.org>

On Mon, 2015-05-18 at 10:43 +0300, Andrey Ryabinin wrote:
> On 05/16/2015 02:27 PM, Paul Bolle wrote:
> > So perhaps the
> > default line should actually read
> > 	default 0xdffffc0000000000 if KASAN
> > 
> > after the move. Would that work?
> 
> Yes, but I would rather add "depends on KASAN".

That would have the same effect, as far as I can see, so if adding
"depends on KASAN" works for you that's fine with me too.

Thanks,


Paul Bolle

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
