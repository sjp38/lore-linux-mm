Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 19D016B025F
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 16:42:49 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id y83so1829484wmc.8
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 13:42:49 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTP id v5si1381158wme.189.2017.11.01.13.42.47
        for <linux-mm@kvack.org>;
        Wed, 01 Nov 2017 13:42:48 -0700 (PDT)
Date: Wed, 1 Nov 2017 21:42:42 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH 01/23] x86, kaiser: prepare assembly for entry/exit CR3
 switching
Message-ID: <20171101204242.whvunv2yvgj2uw22@pd.tnic>
References: <20171031223146.6B47C861@viggo.jf.intel.com>
 <20171031223148.5334003A@viggo.jf.intel.com>
 <20171101181805.3jjzfe6vhmgorjtp@pd.tnic>
 <d991c9c0-ad36-929b-ae1b-05cc97aff19f@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <d991c9c0-ad36-929b-ae1b-05cc97aff19f@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org

On Wed, Nov 01, 2017 at 11:27:48AM -0700, Dave Hansen wrote:
> This allows for a tiny optimization of Andy's that I realize I must have
> blown away at some point.  It lets us do a 32-bit-register instruction
> (and using %eXX) when checking KAISER_SWITCH_MASK instead of a 64-bit
> register via %rXX.
> 
> I don't feel strongly about maintaining that optimization it looks weird
> and surely doesn't actually do much.

Yeah, and consistent syntax would probably bring more.

> Thanks for catching that.  We can kill one of these.  I'm inclined to
> kill the first one.  Looking at the second one since we've just saved
> off ptregs, that should make %rdi safe to clobber without the push/pop
> at all.
> 
> Does that seem like it would work?

Yap, sounds about right.

Thx.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
