Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f45.google.com (mail-oi0-f45.google.com [209.85.218.45])
	by kanga.kvack.org (Postfix) with ESMTP id 95E436B0255
	for <linux-mm@kvack.org>; Mon, 18 Jan 2016 17:24:52 -0500 (EST)
Received: by mail-oi0-f45.google.com with SMTP id p187so164698151oia.2
        for <linux-mm@kvack.org>; Mon, 18 Jan 2016 14:24:52 -0800 (PST)
Received: from mail-ob0-x229.google.com (mail-ob0-x229.google.com. [2607:f8b0:4003:c01::229])
        by mx.google.com with ESMTPS id p9si28624337oev.77.2016.01.18.14.24.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jan 2016 14:24:52 -0800 (PST)
Received: by mail-ob0-x229.google.com with SMTP id py5so204657910obc.2
        for <linux-mm@kvack.org>; Mon, 18 Jan 2016 14:24:52 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1452516679-32040-3-git-send-email-aryabinin@virtuozzo.com>
References: <20160110185916.GD22896@pd.tnic> <1452516679-32040-1-git-send-email-aryabinin@virtuozzo.com>
 <1452516679-32040-3-git-send-email-aryabinin@virtuozzo.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Mon, 18 Jan 2016 14:24:32 -0800
Message-ID: <CALCETrV7un=EBF8HZLdbuB6qoyKfSRz_O1DbNugqytJNWvoV7g@mail.gmail.com>
Subject: Re: [PATCH 2/2] x86/kasan: write protect kasan zero shadow
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, X86 ML <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Mon, Jan 11, 2016 at 4:51 AM, Andrey Ryabinin
<aryabinin@virtuozzo.com> wrote:
> After kasan_init() executed, no one is allowed to write to kasan_zero_page,
> so write protect it.

This seems to work for me.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
