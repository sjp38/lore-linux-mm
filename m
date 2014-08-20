Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id DCD176B0035
	for <linux-mm@kvack.org>; Wed, 20 Aug 2014 11:02:38 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id et14so12637261pad.9
        for <linux-mm@kvack.org>; Wed, 20 Aug 2014 08:02:38 -0700 (PDT)
Received: from blackbird.sr71.net ([2001:19d0:2:6:209:6bff:fe9a:902])
        by mx.google.com with ESMTP id az2si32162180pdb.198.2014.08.20.08.02.33
        for <linux-mm@kvack.org>;
        Wed, 20 Aug 2014 08:02:33 -0700 (PDT)
Message-ID: <53F4B887.7060701@sr71.net>
Date: Wed, 20 Aug 2014 08:02:31 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCH] [v2] TAINT_PERFORMANCE
References: <20140820035751.08C980FB@viggo.jf.intel.com> <20140820081158.GA3991@gmail.com>
In-Reply-To: <20140820081158.GA3991@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: linux-kernel@vger.kernel.org, dave.hansen@linux.intel.com, peterz@infradead.org, mingo@redhat.com, ak@linux.intel.com, tim.c.chen@linux.intel.com, akpm@linux-foundation.org, cl@linux.com, penberg@kernel.org, linux-mm@kvack.org, kirill@shutemov.name, lauraa@codeaurora.org, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>

On 08/20/2014 01:11 AM, Ingo Molnar wrote:
> In any case I don't think it's a good idea to abuse existing 
> facilities just to gain attention: you'll get the extra 
> attention, but the abuse dilutes the utility of those only 
> tangentially related facilities.

I'm happy to rip the TAINT parts out.  I was just hoping that some
tooling might pick up the taint flags today, and this could get picked
up without modification of whatever those tools are.

I was _really_ hoping the dmesg from the taint would be ugly and loud
enough to be sufficient, but it was relatively terse.

> A better option might be to declare known performance killers 
> in /proc/config_debug or so, and maybe print them once at the 
> end of the bootup, with a 'WARNING:' or 'INFO:' prefix. That 
> way tooling (benchmarks, profilers, etc.) can print them, but 
> it's also present in the syslog, just in case.

Sounds reasonable to me.  As long as we have _something_ that shows up
in dmesg, it will help.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
