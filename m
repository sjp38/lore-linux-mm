Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f54.google.com (mail-la0-f54.google.com [209.85.215.54])
	by kanga.kvack.org (Postfix) with ESMTP id 2998F6B0032
	for <linux-mm@kvack.org>; Thu, 11 Jun 2015 10:14:00 -0400 (EDT)
Received: by laew7 with SMTP id w7so5171238lae.1
        for <linux-mm@kvack.org>; Thu, 11 Jun 2015 07:13:59 -0700 (PDT)
Received: from mail-wi0-x22d.google.com (mail-wi0-x22d.google.com. [2a00:1450:400c:c05::22d])
        by mx.google.com with ESMTPS id g7si1437519wjy.213.2015.06.11.07.13.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jun 2015 07:13:58 -0700 (PDT)
Received: by wigg3 with SMTP id g3so76521086wig.1
        for <linux-mm@kvack.org>; Thu, 11 Jun 2015 07:13:57 -0700 (PDT)
Date: Thu, 11 Jun 2015 16:13:53 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [RFC PATCH 00/12] x86/mm: Implement lockless
 pgd_alloc()/pgd_free()
Message-ID: <20150611141353.GA9447@gmail.com>
References: <1434031637-9091-1-git-send-email-mingo@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1434031637-9091-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Denys Vlasenko <dvlasenk@redhat.com>, Brian Gerst <brgerst@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Waiman Long <Waiman.Long@hp.com>


[ I fat-fingered the linux-mm Cc:, so every reply will bounce on that,
  sorry about that  :-/ Fixed it in this mail's Cc: list. ]

* Ingo Molnar <mingo@kernel.org> wrote:

> Waiman Long reported 'pgd_lock' contention on high CPU count systems and 
> proposed moving pgd_lock on a separate cacheline to eliminate false sharing and 
> to reduce some of the lock bouncing overhead.

So 'pgd_lock' is a global lock, used for every new task creation:

arch/x86/mm/fault.c:DEFINE_SPINLOCK(pgd_lock);

which with a sufficiently high CPU count starts to hurt.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
