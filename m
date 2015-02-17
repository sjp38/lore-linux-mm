Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f169.google.com (mail-ob0-f169.google.com [209.85.214.169])
	by kanga.kvack.org (Postfix) with ESMTP id C95686B0032
	for <linux-mm@kvack.org>; Tue, 17 Feb 2015 11:45:54 -0500 (EST)
Received: by mail-ob0-f169.google.com with SMTP id wp4so55175630obc.0
        for <linux-mm@kvack.org>; Tue, 17 Feb 2015 08:45:54 -0800 (PST)
Received: from mail-ob0-x236.google.com (mail-ob0-x236.google.com. [2607:f8b0:4003:c01::236])
        by mx.google.com with ESMTPS id lc2si7564703obb.18.2015.02.17.08.45.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Feb 2015 08:45:53 -0800 (PST)
Received: by mail-ob0-f182.google.com with SMTP id nt9so53981732obb.13
        for <linux-mm@kvack.org>; Tue, 17 Feb 2015 08:45:53 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150217123933.GC26165@pd.tnic>
References: <alpine.LNX.2.00.1502101411280.10719@pobox.suse.cz>
	<CAGXu5jJzs9Ve9so96f6n-=JxP+GR3xYFQYBtZ=mUm+Q7bMAgBw@mail.gmail.com>
	<alpine.LNX.2.00.1502110001480.10719@pobox.suse.cz>
	<alpine.LNX.2.00.1502110010190.10719@pobox.suse.cz>
	<alpine.LNX.2.00.1502131602360.2423@pobox.suse.cz>
	<20150217104443.GC9784@pd.tnic>
	<alpine.LNX.2.00.1502171319040.2279@pobox.suse.cz>
	<20150217123933.GC26165@pd.tnic>
Date: Tue, 17 Feb 2015 08:45:53 -0800
Message-ID: <CAGXu5jL7opSG92o5Gu2tT-NWTfiC7dNSMLynPZWb8uHzUoUqLg@mail.gmail.com>
Subject: Re: [PATCH v2] x86, kaslr: propagate base load address calculation
From: Kees Cook <keescook@chromium.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Jiri Kosina <jkosina@suse.cz>, "H. Peter Anvin" <hpa@linux.intel.com>, LKML <linux-kernel@vger.kernel.org>, live-patching@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>

On Tue, Feb 17, 2015 at 4:39 AM, Borislav Petkov <bp@alien8.de> wrote:
> On Tue, Feb 17, 2015 at 01:21:20PM +0100, Jiri Kosina wrote:
>> I don't have strong feelings either way. It seems slightly nicer
>> to have a predictable oops output format no matter the CONFIG_
>> options and command-line contents, but if you feel like seeing the
>> 'Kernel offset: 0' in 'nokaslr' and !CONFIG_RANDOMIZE_BASE cases is
>> unnecessary noise, feel free to make this change to my patch.
>
> Well, wouldn't it be wrong to print this line if kaslr is disabled?
> Because of the ambiguity in that case: that line could mean either we
> randomized to 0 or kaslr is disabled but you can't know that from the
> "0" in there, right?

Maybe it should say:

Kernel offset: disabled

for maximum clarity?

-Kees

>
> --
> Regards/Gruss,
>     Boris.
>
> ECO tip #101: Trim your mails when you reply.
> --



-- 
Kees Cook
Chrome OS Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
