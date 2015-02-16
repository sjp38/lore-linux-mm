Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f172.google.com (mail-ob0-f172.google.com [209.85.214.172])
	by kanga.kvack.org (Postfix) with ESMTP id 9BA076B0032
	for <linux-mm@kvack.org>; Mon, 16 Feb 2015 14:27:44 -0500 (EST)
Received: by mail-ob0-f172.google.com with SMTP id nt9so45488413obb.3
        for <linux-mm@kvack.org>; Mon, 16 Feb 2015 11:27:44 -0800 (PST)
Received: from mail-ob0-x22f.google.com (mail-ob0-x22f.google.com. [2607:f8b0:4003:c01::22f])
        by mx.google.com with ESMTPS id n8si124122obi.106.2015.02.16.11.27.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Feb 2015 11:27:43 -0800 (PST)
Received: by mail-ob0-f175.google.com with SMTP id va2so45596480obc.6
        for <linux-mm@kvack.org>; Mon, 16 Feb 2015 11:27:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150216115517.GB9500@pd.tnic>
References: <alpine.LNX.2.00.1502101411280.10719@pobox.suse.cz>
	<CAGXu5jJzs9Ve9so96f6n-=JxP+GR3xYFQYBtZ=mUm+Q7bMAgBw@mail.gmail.com>
	<alpine.LNX.2.00.1502110001480.10719@pobox.suse.cz>
	<alpine.LNX.2.00.1502110010190.10719@pobox.suse.cz>
	<alpine.LNX.2.00.1502131602360.2423@pobox.suse.cz>
	<CAGXu5jKSfGzkpNt1-_vRykDCJTCxJg+vRi1D_9a=8auKu-YtgQ@mail.gmail.com>
	<alpine.LNX.2.00.1502132316320.4925@pobox.suse.cz>
	<CAGXu5jL3UMkeHpAxe1RBpnQhLWGquR1NJQx1AsukiwA31AA78g@mail.gmail.com>
	<20150216115517.GB9500@pd.tnic>
Date: Mon, 16 Feb 2015 11:27:42 -0800
Message-ID: <CAGXu5jJVMePoMZwFdH9ROaP2OEW8X-Mr4ztQ37GdP8p+W30ihg@mail.gmail.com>
Subject: Re: [PATCH v2] x86, kaslr: propagate base load address calculation
From: Kees Cook <keescook@chromium.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Jiri Kosina <jkosina@suse.cz>, "H. Peter Anvin" <hpa@linux.intel.com>, LKML <linux-kernel@vger.kernel.org>, live-patching@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>

On Mon, Feb 16, 2015 at 3:55 AM, Borislav Petkov <bp@alien8.de> wrote:
> On Fri, Feb 13, 2015 at 03:25:26PM -0800, Kees Cook wrote:
>> No, no; I agree: a malicious boot loader is a lost cause. I mean
>> mostly from a misbehavior perspective. Like, someone sees "kaslr" in
>> the setup args and thinks they can set it to 1 and boot a kernel, etc.
>> Or they set it to 0, but they lack HIBERNATION and "1" gets appended,
>> but the setup_data parser sees the boot-loader one set to 0, etc. I'm
>> just curious if we should avoid getting some poor system into a
>> confusing state.
>
> Well, we can apply the rule of the last setting sticks and since the
> kernel is always going to be adding the last setup_data element of
> type SETUP_KASLR (the boot loader ones will be somewhere on the list
> in-between and we add to the end), we're fine, no?

Sounds good to me!

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
