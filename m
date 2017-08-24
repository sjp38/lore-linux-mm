Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1BDCC440846
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 13:59:26 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id a186so385781pge.5
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 10:59:26 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id w1si3490212plk.737.2017.08.24.10.59.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Aug 2017 10:59:25 -0700 (PDT)
Subject: Re: [PATCH] x86/mm: fix use-after-free of ldt_struct
References: <20170824175029.76040-1-ebiggers3@gmail.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <43bcad51-b210-c1fa-c729-471fe008ba61@linux.intel.com>
Date: Thu, 24 Aug 2017 10:59:18 -0700
MIME-Version: 1.0
In-Reply-To: <20170824175029.76040-1-ebiggers3@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Biggers <ebiggers3@gmail.com>, x86@kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Eric Biggers <ebiggers@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Christoph Hellwig <hch@lst.de>, Denys Vlasenko <dvlasenk@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, "H . Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Thomas Gleixner <tglx@linutronix.de>, stable@vger.kernel.org

On 08/24/2017 10:50 AM, Eric Biggers wrote:
> --- a/arch/x86/include/asm/mmu_context.h
> +++ b/arch/x86/include/asm/mmu_context.h
> @@ -148,9 +148,7 @@ static inline int init_new_context(struct task_struct *tsk,
>  		mm->context.execute_only_pkey = -1;
>  	}
>  	#endif
> -	init_new_context_ldt(tsk, mm);
> -
> -	return 0;
> +	return init_new_context_ldt(tsk, mm);
>  }

Sheesh.  That was silly.  Thanks for finding and fixing this!  Feel free
to add my ack on it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
