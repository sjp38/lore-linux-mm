Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id A82336B0038
	for <linux-mm@kvack.org>; Sun, 14 Jun 2015 22:47:18 -0400 (EDT)
Received: by padev16 with SMTP id ev16so56168603pad.0
        for <linux-mm@kvack.org>; Sun, 14 Jun 2015 19:47:18 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id kp10si15609596pdb.200.2015.06.14.19.47.17
        for <linux-mm@kvack.org>;
        Sun, 14 Jun 2015 19:47:17 -0700 (PDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: why do we need vmalloc_sync_all?
References: <1434188955-31397-1-git-send-email-mingo@kernel.org>
	<20150613185828.GA32376@redhat.com> <20150614075943.GA810@gmail.com>
	<20150614200623.GB19582@redhat.com>
Date: Sun, 14 Jun 2015 19:47:11 -0700
In-Reply-To: <20150614200623.GB19582@redhat.com> (Oleg Nesterov's message of
	"Sun, 14 Jun 2015 22:06:23 +0200")
Message-ID: <87bnghit74.fsf@tassilo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Ingo Molnar <mingo@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Denys Vlasenko <dvlasenk@redhat.com>, Brian Gerst <brgerst@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Waiman Long <Waiman.Long@hp.com>

Oleg Nesterov <oleg@redhat.com> writes:
>
> But again, the kernel no longer does this? do_page_fault() does vmalloc_fault()
> without notify_die(). If it fails, I do not see how/why a modular DIE_OOPS
> handler could try to resolve this problem and trigger another fault.

The same problem can happen from NMI handlers or machine check
handlers. It's not necessarily tied to page faults only.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
