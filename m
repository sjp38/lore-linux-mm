Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 226646B016A
	for <linux-mm@kvack.org>; Mon, 22 Aug 2011 16:18:02 -0400 (EDT)
Message-ID: <4E52B96B.8040404@zytor.com>
Date: Mon, 22 Aug 2011 13:17:47 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [RFC] x86, mm: start mmap allocation for libs from low addresses
References: <20110812102954.GA3496@albatros> <ccea406f-62be-4344-8036-a1b092937fe9@email.android.com> <20110816090540.GA7857@albatros> <20110822101730.GA3346@albatros> <4E5290D6.5050406@zytor.com> <20110822201418.GA3176@albatros>
In-Reply-To: <20110822201418.GA3176@albatros>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vasiliy Kulikov <segoon@openwall.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, kernel-hardening@lists.openwall.com, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 08/22/2011 01:14 PM, Vasiliy Kulikov wrote:
> 
>> Code-wise:
>>
>> The code is horrific; it is full of open-coded magic numbers;
> 
> Agreed, the magic needs macro definition and comments.
> 
>> it also
>> puts a function called arch_get_unmapped_exec_area() in a generic file,
>> which could best be described as "WTF" -- the arch_ prefix we use
>> specifically to denote a per-architecture hook function.
> 
> Agreed.  But I'd want to leave it in mm/mmap.c as it's likely be used by
> other archs - the changes are bitness specific, not arch specific.  Is
> it OK if I do this?
> 
> #ifndef HAVE_ARCH_UNMAPPED_EXEC_AREA
> void *arch_get_unmapped_exec_area(...)
> {
>     ...
> }
> #endif
> 

Only if this is really an architecture-specific function overridden in
specific architectures.  I'm not so sure that applies here.
Furthermore, I'm not even all that sure what this function *does*.

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
