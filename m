Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3FD4D6B0253
	for <linux-mm@kvack.org>; Fri,  1 Dec 2017 10:37:21 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id l4so6038889wre.10
        for <linux-mm@kvack.org>; Fri, 01 Dec 2017 07:37:21 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTP id 89si5065927wri.18.2017.12.01.07.37.19
        for <linux-mm@kvack.org>;
        Fri, 01 Dec 2017 07:37:20 -0800 (PST)
Date: Fri, 1 Dec 2017 16:37:13 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: KAISER: kexec triggers a warning
Message-ID: <20171201153713.apdoi6em7c4iynlr@pd.tnic>
References: <03012d01-4d04-1d58-aa93-425f142f9292@canonical.com>
 <84c7dd7d-5e01-627e-6f26-5c1e30a87683@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <84c7dd7d-5e01-627e-6f26-5c1e30a87683@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Juerg Haefliger <juerg.haefliger@canonical.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mingo@kernel.org, tglx@linutronix.de, peterz@infradead.org, hughd@google.com, luto@kernel.org

On Fri, Dec 01, 2017 at 07:31:36AM -0800, Dave Hansen wrote:
> The only question is whether we want to preserve _some_ kind of warning
> there, or just axe it entirely.

Right, my fear would be if we keep it, then we'd have to go and
whitelist or somehow track those users which are an exception...

OTOH, it might be prudent to have a warning to catch such abnormal
situations...

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
