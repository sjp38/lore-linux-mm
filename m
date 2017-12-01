Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 923F66B0261
	for <linux-mm@kvack.org>; Fri,  1 Dec 2017 12:03:28 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id k126so1256039wmd.5
        for <linux-mm@kvack.org>; Fri, 01 Dec 2017 09:03:28 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTP id q16si2914918wre.202.2017.12.01.09.03.27
        for <linux-mm@kvack.org>;
        Fri, 01 Dec 2017 09:03:27 -0800 (PST)
Date: Fri, 1 Dec 2017 18:03:18 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: KAISER: kexec triggers a warning
Message-ID: <20171201170318.zlncyzuqksxivbhx@pd.tnic>
References: <03012d01-4d04-1d58-aa93-425f142f9292@canonical.com>
 <84c7dd7d-5e01-627e-6f26-5c1e30a87683@linux.intel.com>
 <20171201153713.apdoi6em7c4iynlr@pd.tnic>
 <20171201163850.GC26327@u40b0340c692b58f6553c.ant.amazon.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20171201163850.GC26327@u40b0340c692b58f6553c.ant.amazon.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eduardo Valentin <eduval@amazon.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Juerg Haefliger <juerg.haefliger@canonical.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mingo@kernel.org, tglx@linutronix.de, peterz@infradead.org, hughd@google.com, luto@kernel.org

On Fri, Dec 01, 2017 at 08:38:50AM -0800, Eduardo Valentin wrote:
> But a warn like that on the kexec/kdump path can be scary for regular
> / unware users, specially considering that kexec is almost common
> place for regular reboot.

... thus the whitelisting/tracking/... of legitimate users so that we
warn only for the abnormal cases.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
