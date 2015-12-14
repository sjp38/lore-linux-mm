Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id AC5B96B0255
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 18:39:32 -0500 (EST)
Received: by mail-ig0-f180.google.com with SMTP id ph11so95580135igc.1
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 15:39:32 -0800 (PST)
Received: from mail-io0-x236.google.com (mail-io0-x236.google.com. [2607:f8b0:4001:c06::236])
        by mx.google.com with ESMTPS id o35si266234ioi.152.2015.12.14.15.39.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Dec 2015 15:39:32 -0800 (PST)
Received: by mail-io0-x236.google.com with SMTP id e126so1333063ioa.1
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 15:39:32 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <566F52CE.6080501@sr71.net>
References: <20151214190542.39C4886D@viggo.jf.intel.com>
	<20151214190632.6A741188@viggo.jf.intel.com>
	<CAGXu5jJ5oHy11Uy4N2m1aa2A9ar9-oH_kez9jq=gM8CVSj734Q@mail.gmail.com>
	<566F52CE.6080501@sr71.net>
Date: Mon, 14 Dec 2015 15:39:31 -0800
Message-ID: <CAGXu5j+7Yv36riu4TG_EksPkEz3XzMNRWvCde_6VrhmkWChxSA@mail.gmail.com>
Subject: Re: [PATCH 31/32] x86, pkeys: execute-only support
From: Kees Cook <keescook@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Dave Hansen <dave.hansen@linux.intel.com>

On Mon, Dec 14, 2015 at 3:37 PM, Dave Hansen <dave@sr71.net> wrote:
> On 12/14/2015 12:05 PM, Kees Cook wrote:
>> On Mon, Dec 14, 2015 at 11:06 AM, Dave Hansen <dave@sr71.net> wrote:
>>> > From: Dave Hansen <dave.hansen@linux.intel.com>
>>> > Protection keys provide new page-based protection in hardware.
>>> > But, they have an interesting attribute: they only affect data
>>> > accesses and never affect instruction fetches.  That means that
>>> > if we set up some memory which is set as "access-disabled" via
>>> > protection keys, we can still execute from it.
> ...
>>> > I haven't found any userspace that does this today.
>> To realistically take advantage of this, it sounds like the linker
>> would need to know to keep bss and data page-aligned away from text,
>> and then set text to PROT_EXEC only?
>>
>> Do you have any example linker scripts for this?
>
> Nope.  My linker-fu is weak.
>
> Can we even depend on the linker by itself?  Even if the sections were
> marked --x, we can't actually use them with those permissions unless we
> have protection keys.
>
> Do we need some special tag on the section to tell the linker to map it
> as --x under some conditions and r-x for others?

Yeah, dunno. I was curious to see this working on a real example
first, and then we could figure out how the linker should behave
generally. Sounds like we need some kind of ELF flag to say "please
use unreadable-exec memory mappings for this program, too.

-Kees

-- 
Kees Cook
Chrome OS & Brillo Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
