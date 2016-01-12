Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com [209.85.214.173])
	by kanga.kvack.org (Postfix) with ESMTP id F270E680F80
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 19:30:39 -0500 (EST)
Received: by mail-ob0-f173.google.com with SMTP id vt7so13567527obb.1
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 16:30:39 -0800 (PST)
Received: from mail-oi0-x229.google.com (mail-oi0-x229.google.com. [2607:f8b0:4003:c06::229])
        by mx.google.com with ESMTPS id b188si1083267oih.29.2016.01.11.16.30.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jan 2016 16:30:39 -0800 (PST)
Received: by mail-oi0-x229.google.com with SMTP id k206so62556442oia.1
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 16:30:39 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160112002645.GA10179@agluck-desk.sc.intel.com>
References: <cover.1452297867.git.tony.luck@intel.com> <19f6403f2b04d3448ed2ac958e656645d8b6e70c.1452297867.git.tony.luck@intel.com>
 <CALCETrVqn58pMkMc09vbtNdbU2VFtQ=W8APZ0EqtLCh3JGvxoA@mail.gmail.com> <20160112002645.GA10179@agluck-desk.sc.intel.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Mon, 11 Jan 2016 16:30:19 -0800
Message-ID: <CALCETrUoOsh2BHYcOOQ3uh1rqnXdyf-OCGf9mnCn+yGDibv4iQ@mail.gmail.com>
Subject: Re: [PATCH v8 3/3] x86, mce: Add __mcsafe_copy()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: linux-nvdimm <linux-nvdimm@ml01.01.org>, Dan Williams <dan.j.williams@intel.com>, Borislav Petkov <bp@alien8.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Robert <elliott@hpe.com>, Ingo Molnar <mingo@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, X86 ML <x86@kernel.org>

On Mon, Jan 11, 2016 at 4:26 PM, Luck, Tony <tony.luck@intel.com> wrote:
> On Fri, Jan 08, 2016 at 05:49:30PM -0800, Andy Lutomirski wrote:
>> Also, what's the sfence for?  You don't seem to be using any
>> non-temporal operations.
>
> So I deleted the "sfence" and now I just have a comment
> at the 100: label.
>
> 37:
>         shl $6,%ecx
>         lea -48(%ecx,%edx),%edx
>         jmp 100f
> 38:
>         shl $6,%ecx
>         lea -56(%ecx,%edx),%edx
>         jmp 100f
> 39:
>         lea (%rdx,%rcx,8),%rdx
>         jmp 100f
> 40:
>         mov %ecx,%edx
> 100:
>         /* %rax set the fault number in fixup_exception() */
>         ret
>
> Should I just change all the "jmp 100f" into "ret"?  There
> aren't any tools that will be confused that the function
> has 10 returns, are there?
>

Given that gcc does that too, it should be fine.

--Andy\

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
