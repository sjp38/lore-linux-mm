Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f175.google.com (mail-we0-f175.google.com [74.125.82.175])
	by kanga.kvack.org (Postfix) with ESMTP id CD20A6B006C
	for <linux-mm@kvack.org>; Wed, 18 Feb 2015 03:33:40 -0500 (EST)
Received: by wesw62 with SMTP id w62so3172724wes.9
        for <linux-mm@kvack.org>; Wed, 18 Feb 2015 00:33:40 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id cy7si33580337wib.45.2015.02.18.00.33.38
        for <linux-mm@kvack.org>;
        Wed, 18 Feb 2015 00:33:39 -0800 (PST)
Date: Wed, 18 Feb 2015 09:32:49 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v2] x86, kaslr: propagate base load address calculation
Message-ID: <20150218083248.GA3211@pd.tnic>
References: <CAGXu5jJzs9Ve9so96f6n-=JxP+GR3xYFQYBtZ=mUm+Q7bMAgBw@mail.gmail.com>
 <alpine.LNX.2.00.1502110001480.10719@pobox.suse.cz>
 <alpine.LNX.2.00.1502110010190.10719@pobox.suse.cz>
 <alpine.LNX.2.00.1502131602360.2423@pobox.suse.cz>
 <20150217104443.GC9784@pd.tnic>
 <alpine.LNX.2.00.1502171319040.2279@pobox.suse.cz>
 <20150217123933.GC26165@pd.tnic>
 <CAGXu5jL7opSG92o5Gu2tT-NWTfiC7dNSMLynPZWb8uHzUoUqLg@mail.gmail.com>
 <20150217223105.GI26165@pd.tnic>
 <CAGXu5jKQDfhvr04OAxeFO+nhpnVgQ40444SvBPpCZkF4CVa28g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CAGXu5jKQDfhvr04OAxeFO+nhpnVgQ40444SvBPpCZkF4CVa28g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Jiri Kosina <jkosina@suse.cz>, "H. Peter Anvin" <hpa@linux.intel.com>, LKML <linux-kernel@vger.kernel.org>, live-patching@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>

On Tue, Feb 17, 2015 at 07:33:40PM -0800, Kees Cook wrote:
> You are the best. :)

Of course, the bestest! :-P

> Acked-by: Kees Cook <keescook@chromium.org>

Thanks Kees, I'll fold it into Jiri's patch and forward.

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
