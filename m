Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 1AAC56B0072
	for <linux-mm@kvack.org>; Tue, 17 Feb 2015 07:40:24 -0500 (EST)
Received: by mail-wg0-f42.google.com with SMTP id n12so18516312wgh.1
        for <linux-mm@kvack.org>; Tue, 17 Feb 2015 04:40:23 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id v1si28541109wij.61.2015.02.17.04.40.21
        for <linux-mm@kvack.org>;
        Tue, 17 Feb 2015 04:40:22 -0800 (PST)
Date: Tue, 17 Feb 2015 13:39:33 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v2] x86, kaslr: propagate base load address calculation
Message-ID: <20150217123933.GC26165@pd.tnic>
References: <alpine.LNX.2.00.1502101411280.10719@pobox.suse.cz>
 <CAGXu5jJzs9Ve9so96f6n-=JxP+GR3xYFQYBtZ=mUm+Q7bMAgBw@mail.gmail.com>
 <alpine.LNX.2.00.1502110001480.10719@pobox.suse.cz>
 <alpine.LNX.2.00.1502110010190.10719@pobox.suse.cz>
 <alpine.LNX.2.00.1502131602360.2423@pobox.suse.cz>
 <20150217104443.GC9784@pd.tnic>
 <alpine.LNX.2.00.1502171319040.2279@pobox.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1502171319040.2279@pobox.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Kosina <jkosina@suse.cz>
Cc: Kees Cook <keescook@chromium.org>, "H. Peter Anvin" <hpa@linux.intel.com>, LKML <linux-kernel@vger.kernel.org>, live-patching@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>

On Tue, Feb 17, 2015 at 01:21:20PM +0100, Jiri Kosina wrote:
> I don't have strong feelings either way. It seems slightly nicer
> to have a predictable oops output format no matter the CONFIG_
> options and command-line contents, but if you feel like seeing the
> 'Kernel offset: 0' in 'nokaslr' and !CONFIG_RANDOMIZE_BASE cases is
> unnecessary noise, feel free to make this change to my patch.

Well, wouldn't it be wrong to print this line if kaslr is disabled?
Because of the ambiguity in that case: that line could mean either we
randomized to 0 or kaslr is disabled but you can't know that from the
"0" in there, right?

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
