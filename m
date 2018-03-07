Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id E85096B000A
	for <linux-mm@kvack.org>; Wed,  7 Mar 2018 12:32:03 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id h33so1653765wrh.10
        for <linux-mm@kvack.org>; Wed, 07 Mar 2018 09:32:03 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id e5si4364979wrd.9.2018.03.07.09.32.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Mar 2018 09:32:02 -0800 (PST)
Date: Wed, 7 Mar 2018 09:32:02 -0800
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 0/2] Backport IBPB on context switch to non-dumpable
 process
Message-ID: <20180307173202.GK7097@kroah.com>
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

Applied to 4.9.y, but I need a separate set of patches for 4.4.y in
order for them to work there.  Can you provide that?

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
