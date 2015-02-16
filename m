Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id A79F06B0032
	for <linux-mm@kvack.org>; Mon, 16 Feb 2015 06:56:05 -0500 (EST)
Received: by mail-wi0-f174.google.com with SMTP id em10so25543285wid.1
        for <linux-mm@kvack.org>; Mon, 16 Feb 2015 03:56:05 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id fm6si21521168wjc.133.2015.02.16.03.56.03
        for <linux-mm@kvack.org>;
        Mon, 16 Feb 2015 03:56:03 -0800 (PST)
Date: Mon, 16 Feb 2015 12:55:17 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v2] x86, kaslr: propagate base load address calculation
Message-ID: <20150216115517.GB9500@pd.tnic>
References: <alpine.LNX.2.00.1502101411280.10719@pobox.suse.cz>
 <CAGXu5jJzs9Ve9so96f6n-=JxP+GR3xYFQYBtZ=mUm+Q7bMAgBw@mail.gmail.com>
 <alpine.LNX.2.00.1502110001480.10719@pobox.suse.cz>
 <alpine.LNX.2.00.1502110010190.10719@pobox.suse.cz>
 <alpine.LNX.2.00.1502131602360.2423@pobox.suse.cz>
 <CAGXu5jKSfGzkpNt1-_vRykDCJTCxJg+vRi1D_9a=8auKu-YtgQ@mail.gmail.com>
 <alpine.LNX.2.00.1502132316320.4925@pobox.suse.cz>
 <CAGXu5jL3UMkeHpAxe1RBpnQhLWGquR1NJQx1AsukiwA31AA78g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CAGXu5jL3UMkeHpAxe1RBpnQhLWGquR1NJQx1AsukiwA31AA78g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Jiri Kosina <jkosina@suse.cz>, "H. Peter Anvin" <hpa@linux.intel.com>, LKML <linux-kernel@vger.kernel.org>, live-patching@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>

On Fri, Feb 13, 2015 at 03:25:26PM -0800, Kees Cook wrote:
> No, no; I agree: a malicious boot loader is a lost cause. I mean
> mostly from a misbehavior perspective. Like, someone sees "kaslr" in
> the setup args and thinks they can set it to 1 and boot a kernel, etc.
> Or they set it to 0, but they lack HIBERNATION and "1" gets appended,
> but the setup_data parser sees the boot-loader one set to 0, etc. I'm
> just curious if we should avoid getting some poor system into a
> confusing state.

Well, we can apply the rule of the last setting sticks and since the
kernel is always going to be adding the last setup_data element of
type SETUP_KASLR (the boot loader ones will be somewhere on the list
in-between and we add to the end), we're fine, no?

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
