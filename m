Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 59387440CD7
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 10:59:35 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id o88so3340003wrb.18
        for <linux-mm@kvack.org>; Thu, 09 Nov 2017 07:59:35 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTP id v13si5898717wrg.499.2017.11.09.07.59.34
        for <linux-mm@kvack.org>;
        Thu, 09 Nov 2017 07:59:34 -0800 (PST)
Date: Thu, 9 Nov 2017 16:59:30 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH 05/30] x86, kaiser: prepare assembly for entry/exit CR3
 switching
Message-ID: <20171109155930.5oipdezx4bybsw55@pd.tnic>
References: <20171108194646.907A1942@viggo.jf.intel.com>
 <20171108194654.B960A09E@viggo.jf.intel.com>
 <20171109132016.ntku742dgppt7k4v@pd.tnic>
 <e676a8bb-6966-6c01-d62c-bfbc476d5f3e@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <e676a8bb-6966-6c01-d62c-bfbc476d5f3e@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org

On Thu, Nov 09, 2017 at 07:34:52AM -0800, Dave Hansen wrote:
> On 11/09/2017 05:20 AM, Borislav Petkov wrote:
> > What branch is that one against?
> 
> It's against Andy's entry rework:
> 
> https://git.kernel.org/pub/scm/linux/kernel/git/luto/linux.git/log/?h=x86/entry_consolidation

Ah, so this is what

" * Updated to be on top of Andy L's new entry code"

means.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
