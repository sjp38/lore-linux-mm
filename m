Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id A76196B0169
	for <linux-mm@kvack.org>; Sat, 13 Aug 2011 02:26:21 -0400 (EDT)
Received: by bkbzt4 with SMTP id zt4so2943038bkb.14
        for <linux-mm@kvack.org>; Fri, 12 Aug 2011 23:26:18 -0700 (PDT)
Date: Sat, 13 Aug 2011 10:26:14 +0400
From: Vasiliy Kulikov <segoon@openwall.com>
Subject: Re: [RFC] x86, mm: start mmap allocation for libs from low
 addresses
Message-ID: <20110813062614.GD3851@albatros>
References: <20110812102954.GA3496@albatros>
 <ccea406f-62be-4344-8036-a1b092937fe9@email.android.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ccea406f-62be-4344-8036-a1b092937fe9@email.android.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, kernel-hardening@lists.openwall.com, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Aug 12, 2011 at 18:19 -0500, H. Peter Anvin wrote:
> This also greatly reduces the address space available for randomization,
> and may get in the way of the default brk.  Is this a net win or lose?

If the executable image is not randomized and is located out of
ASCII-armor, then yes, such allocation doesn't help much.

>  Also, this zero byte is going to be at the last address, which means it might not help.  How about addresses of the form 0xAA00B000 instead?  The last bits are always 000 for a page address, of course...

It leaves only 64kb of library protected, which is useless for most of
programs.

Thanks,

-- 
Vasiliy Kulikov
http://www.openwall.com - bringing security into open computing environments

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
