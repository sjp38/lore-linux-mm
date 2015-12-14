Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 608296B0255
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 18:44:06 -0500 (EST)
Received: by pff63 with SMTP id 63so19479263pff.2
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 15:44:06 -0800 (PST)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id s8si20183327pfa.140.2015.12.14.15.44.05
        for <linux-mm@kvack.org>;
        Mon, 14 Dec 2015 15:44:05 -0800 (PST)
Subject: Re: [PATCH 31/32] x86, pkeys: execute-only support
References: <20151214190542.39C4886D@viggo.jf.intel.com>
 <20151214190632.6A741188@viggo.jf.intel.com>
 <CAGXu5jJ5oHy11Uy4N2m1aa2A9ar9-oH_kez9jq=gM8CVSj734Q@mail.gmail.com>
 <566F52CE.6080501@sr71.net>
 <CALCETrWZbBD9vOrGn+=Qr-mKVzSKkoUbo6u7u5rpG5S0RB6v+Q@mail.gmail.com>
From: Dave Hansen <dave@sr71.net>
Message-ID: <566F5444.7000302@sr71.net>
Date: Mon, 14 Dec 2015 15:44:04 -0800
MIME-Version: 1.0
In-Reply-To: <CALCETrWZbBD9vOrGn+=Qr-mKVzSKkoUbo6u7u5rpG5S0RB6v+Q@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Kees Cook <keescook@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@linux.intel.com>

On 12/14/2015 03:39 PM, Andy Lutomirski wrote:
>> > Nope.  My linker-fu is weak.
>> >
>> > Can we even depend on the linker by itself?  Even if the sections were
>> > marked --x, we can't actually use them with those permissions unless we
>> > have protection keys.
>> >
>> > Do we need some special tag on the section to tell the linker to map it
>> > as --x under some conditions and r-x for others?
>> >
> Why?  Wouldn't --x just end up acting like r-x if PKRU is absent?

An app doing --x would expect it to be unreadable.  I don't think we can
just silently turn it in to r-x.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
