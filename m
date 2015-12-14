Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f48.google.com (mail-oi0-f48.google.com [209.85.218.48])
	by kanga.kvack.org (Postfix) with ESMTP id DAF466B0255
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 18:47:44 -0500 (EST)
Received: by oiai186 with SMTP id i186so34382276oia.2
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 15:47:44 -0800 (PST)
Received: from mail-oi0-x234.google.com (mail-oi0-x234.google.com. [2607:f8b0:4003:c06::234])
        by mx.google.com with ESMTPS id e142si11560697oig.125.2015.12.14.15.47.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Dec 2015 15:47:44 -0800 (PST)
Received: by oiai186 with SMTP id i186so34382188oia.2
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 15:47:44 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <566F5444.7000302@sr71.net>
References: <20151214190542.39C4886D@viggo.jf.intel.com> <20151214190632.6A741188@viggo.jf.intel.com>
 <CAGXu5jJ5oHy11Uy4N2m1aa2A9ar9-oH_kez9jq=gM8CVSj734Q@mail.gmail.com>
 <566F52CE.6080501@sr71.net> <CALCETrWZbBD9vOrGn+=Qr-mKVzSKkoUbo6u7u5rpG5S0RB6v+Q@mail.gmail.com>
 <566F5444.7000302@sr71.net>
From: Andy Lutomirski <luto@amacapital.net>
Date: Mon, 14 Dec 2015 15:47:24 -0800
Message-ID: <CALCETrXhNXx_csPnXcSaPvgY52NN8kadvd8XG8FQ3dcMfvftOg@mail.gmail.com>
Subject: Re: [PATCH 31/32] x86, pkeys: execute-only support
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: Kees Cook <keescook@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@linux.intel.com>

On Mon, Dec 14, 2015 at 3:44 PM, Dave Hansen <dave@sr71.net> wrote:
> On 12/14/2015 03:39 PM, Andy Lutomirski wrote:
>>> > Nope.  My linker-fu is weak.
>>> >
>>> > Can we even depend on the linker by itself?  Even if the sections were
>>> > marked --x, we can't actually use them with those permissions unless we
>>> > have protection keys.
>>> >
>>> > Do we need some special tag on the section to tell the linker to map it
>>> > as --x under some conditions and r-x for others?
>>> >
>> Why?  Wouldn't --x just end up acting like r-x if PKRU is absent?
>
> An app doing --x would expect it to be unreadable.  I don't think we can
> just silently turn it in to r-x.

I don't see why.  After all, an app doing --x right now gets rx.  An
app doing r-- still gets r-x on some systems.

--Andy


-- 
Andy Lutomirski
AMA Capital Management, LLC

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
