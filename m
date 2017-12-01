Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id EAB196B0069
	for <linux-mm@kvack.org>; Fri,  1 Dec 2017 11:38:59 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id i33so4675313pld.0
        for <linux-mm@kvack.org>; Fri, 01 Dec 2017 08:38:59 -0800 (PST)
Received: from smtp-fw-9102.amazon.com (smtp-fw-9102.amazon.com. [207.171.184.29])
        by mx.google.com with ESMTPS id d30si5173087pld.747.2017.12.01.08.38.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Dec 2017 08:38:59 -0800 (PST)
Date: Fri, 1 Dec 2017 08:38:50 -0800
From: Eduardo Valentin <eduval@amazon.com>
Subject: Re: KAISER: kexec triggers a warning
Message-ID: <20171201163850.GC26327@u40b0340c692b58f6553c.ant.amazon.com>
References: <03012d01-4d04-1d58-aa93-425f142f9292@canonical.com>
 <84c7dd7d-5e01-627e-6f26-5c1e30a87683@linux.intel.com>
 <20171201153713.apdoi6em7c4iynlr@pd.tnic>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20171201153713.apdoi6em7c4iynlr@pd.tnic>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Juerg Haefliger <juerg.haefliger@canonical.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mingo@kernel.org, tglx@linutronix.de, peterz@infradead.org, hughd@google.com, luto@kernel.org

On Fri, Dec 01, 2017 at 04:37:13PM +0100, Borislav Petkov wrote:
> On Fri, Dec 01, 2017 at 07:31:36AM -0800, Dave Hansen wrote:
> > The only question is whether we want to preserve _some_ kind of warning
> > there, or just axe it entirely.
> 
> Right, my fear would be if we keep it, then we'd have to go and
> whitelist or somehow track those users which are an exception...
> 
> OTOH, it might be prudent to have a warning to catch such abnormal
> situations...

But a warn like that on the kexec/kdump path can be scary for regular / unware users,
specially considering that kexec is almost common place for regular reboot.

> 
> -- 
> Regards/Gruss,
>     Boris.
> 
> Good mailing practices for 400: avoid top-posting and trim the reply.
> 

-- 
All the best,
Eduardo Valentin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
