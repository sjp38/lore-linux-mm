Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id E93DF6B0253
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 05:07:55 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id t139so996522wmt.7
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 02:07:55 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTP id m76si352859wmi.36.2017.11.01.02.07.54
        for <linux-mm@kvack.org>;
        Wed, 01 Nov 2017 02:07:54 -0700 (PDT)
Date: Wed, 1 Nov 2017 10:07:50 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH 23/23] x86, kaiser: add Kconfig
Message-ID: <20171101090750.fz3mgz5sefdkgwso@pd.tnic>
References: <20171031223146.6B47C861@viggo.jf.intel.com>
 <20171031223228.9F2B69B4@viggo.jf.intel.com>
 <CAGXu5jK3nwcO=520a0V22bs_-8wBYAO+E5aeX53PUfevA2KvVQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CAGXu5jK3nwcO=520a0V22bs_-8wBYAO+E5aeX53PUfevA2KvVQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@google.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, Andy Lutomirski <luto@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, x86@kernel.org

On Tue, Oct 31, 2017 at 04:59:37PM -0700, Kees Cook wrote:
> A quick look through "#ifdef CONFIG_KAISER" looks like it might be
> possible to make this a runtime setting at some point. When doing
> KASLR, it was much more useful to make this runtime selectable so that
> distro kernels could build the support in, but let users decide if
> they wanted to enable it.

Yes please.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
