Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id C168F6B0070
	for <linux-mm@kvack.org>; Tue, 10 Feb 2015 18:13:33 -0500 (EST)
Received: by mail-wi0-f177.google.com with SMTP id bs8so936675wib.4
        for <linux-mm@kvack.org>; Tue, 10 Feb 2015 15:13:33 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bb4si508016wib.70.2015.02.10.15.13.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 10 Feb 2015 15:13:32 -0800 (PST)
Date: Wed, 11 Feb 2015 00:13:30 +0100 (CET)
From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: [PATCH] x86, kaslr: propagate base load address calculation
In-Reply-To: <alpine.LNX.2.00.1502110001480.10719@pobox.suse.cz>
Message-ID: <alpine.LNX.2.00.1502110010190.10719@pobox.suse.cz>
References: <alpine.LNX.2.00.1502101411280.10719@pobox.suse.cz> <CAGXu5jJzs9Ve9so96f6n-=JxP+GR3xYFQYBtZ=mUm+Q7bMAgBw@mail.gmail.com> <alpine.LNX.2.00.1502110001480.10719@pobox.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: "H. Peter Anvin" <hpa@linux.intel.com>, LKML <linux-kernel@vger.kernel.org>, live-patching@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>

On Wed, 11 Feb 2015, Jiri Kosina wrote:

> Alternatively, we can forbid zero-sized randomization, and always enforce 
> at least some minimal offset to be chosen in case zero would be chosen.

Okay, I see, that might not be always possible, depending on the memory 
map layout.

So I'll just send you a respin of my previous patch tomorrow that would, 
instead of defining __KERNEL_OFFSET as a particular value, introduce a 
simple global flag which would indicate whether kaslr is in place or not.

-- 
Jiri Kosina
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
