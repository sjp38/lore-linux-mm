Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7C8A46B0003
	for <linux-mm@kvack.org>; Sat,  3 Mar 2018 03:55:01 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id d18so7938256wre.6
        for <linux-mm@kvack.org>; Sat, 03 Mar 2018 00:55:01 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b81si1905545wmd.97.2018.03.03.00.54.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 03 Mar 2018 00:54:59 -0800 (PST)
Date: Sat, 3 Mar 2018 09:54:54 +0100
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 0/2] Backport IBPB on context switch to non-dumpable
 process
Message-ID: <20180303085454.GA23988@kroah.com>
References: <cover.1520026221.git.tim.c.chen@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1520026221.git.tim.c.chen@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: stable@vger.kernel.org, Andy Lutomirski <luto@kernel.org>, Nadav Amit <nadav.amit@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Arjan van de Ven <arjan@linux.intel.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, David Woodhouse <dwmw@amazon.co.uk>, ak@linux.intel.com, karahmed@amazon.de, pbonzini@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Mar 02, 2018 at 01:32:08PM -0800, Tim Chen wrote:
> Greg,
> 
> I will like to propose backporting "x86/speculation: Use Indirect Branch
> Prediction Barrier on context switch" from commit 18bf3c3e in upstream
> to 4.9 and 4.4 stable.  The patch has already been ported to 4.14 and
> 4.15 stable.  The patch needs mm context id that Andy added in commit
> f39681ed. I have lifted the mm context id change from Andy's upstream
> patch and included it here.

What does this patch "fix" in those older kernels?  Is this a
performance improvement or something else?

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
