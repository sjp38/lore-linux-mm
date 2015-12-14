Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id BCE416B0256
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 18:37:54 -0500 (EST)
Received: by padhk6 with SMTP id hk6so71618593pad.2
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 15:37:54 -0800 (PST)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id xj5si9620714pab.84.2015.12.14.15.37.52
        for <linux-mm@kvack.org>;
        Mon, 14 Dec 2015 15:37:52 -0800 (PST)
Subject: Re: [PATCH 31/32] x86, pkeys: execute-only support
References: <20151214190542.39C4886D@viggo.jf.intel.com>
 <20151214190632.6A741188@viggo.jf.intel.com>
 <CAGXu5jJ5oHy11Uy4N2m1aa2A9ar9-oH_kez9jq=gM8CVSj734Q@mail.gmail.com>
From: Dave Hansen <dave@sr71.net>
Message-ID: <566F52CE.6080501@sr71.net>
Date: Mon, 14 Dec 2015 15:37:50 -0800
MIME-Version: 1.0
In-Reply-To: <CAGXu5jJ5oHy11Uy4N2m1aa2A9ar9-oH_kez9jq=gM8CVSj734Q@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@google.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Dave Hansen <dave.hansen@linux.intel.com>

On 12/14/2015 12:05 PM, Kees Cook wrote:
> On Mon, Dec 14, 2015 at 11:06 AM, Dave Hansen <dave@sr71.net> wrote:
>> > From: Dave Hansen <dave.hansen@linux.intel.com>
>> > Protection keys provide new page-based protection in hardware.
>> > But, they have an interesting attribute: they only affect data
>> > accesses and never affect instruction fetches.  That means that
>> > if we set up some memory which is set as "access-disabled" via
>> > protection keys, we can still execute from it.
...
>> > I haven't found any userspace that does this today.
> To realistically take advantage of this, it sounds like the linker
> would need to know to keep bss and data page-aligned away from text,
> and then set text to PROT_EXEC only?
> 
> Do you have any example linker scripts for this?

Nope.  My linker-fu is weak.

Can we even depend on the linker by itself?  Even if the sections were
marked --x, we can't actually use them with those permissions unless we
have protection keys.

Do we need some special tag on the section to tell the linker to map it
as --x under some conditions and r-x for others?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
