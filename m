Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f174.google.com (mail-ob0-f174.google.com [209.85.214.174])
	by kanga.kvack.org (Postfix) with ESMTP id 5FEAB828DE
	for <linux-mm@kvack.org>; Thu,  7 Jan 2016 17:25:25 -0500 (EST)
Received: by mail-ob0-f174.google.com with SMTP id bx1so312290137obb.0
        for <linux-mm@kvack.org>; Thu, 07 Jan 2016 14:25:25 -0800 (PST)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id e189si34300750oif.93.2016.01.07.14.25.24
        for <linux-mm@kvack.org>;
        Thu, 07 Jan 2016 14:25:24 -0800 (PST)
Subject: Re: [PATCH 31/31] x86, pkeys: execute-only support
References: <20160107000104.1A105322@viggo.jf.intel.com>
 <20160107000148.ED5D13DF@viggo.jf.intel.com>
 <CAGXu5jJx=EMnnGX4k8ZQSnsPV+4zQXGfC+3KF_qAWJVArt8M2Q@mail.gmail.com>
From: Dave Hansen <dave@sr71.net>
Message-ID: <568EE5D3.1080006@sr71.net>
Date: Thu, 7 Jan 2016 14:25:23 -0800
MIME-Version: 1.0
In-Reply-To: <CAGXu5jJx=EMnnGX4k8ZQSnsPV+4zQXGfC+3KF_qAWJVArt8M2Q@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@google.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>

On 01/07/2016 01:02 PM, Kees Cook wrote:
>> > I haven't found any userspace that does this today.  With this
>> > facility in place, we expect userspace to move to use it
>> > eventually.
> And the magic benefit here is that linker/loaders can switch to just
> PROT_EXEC without PROT_READ, and everything that doesn't support this
> protection will silently include PROT_READ, so no runtime detection by
> the loader is needed.

Yep, completely agree.

I'll update the description.

>> > The security provided by this approach is not comprehensive.  The
> Perhaps specifically mention what it does provide, which would be
> protection against leaking executable memory contents, as generally
> done by attackers who are attempting to find ROP gadgets on the fly.

Good point.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
