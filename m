Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 2DE17680F80
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 19:26:47 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id ho8so68631748pac.2
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 16:26:47 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id d1si43508181pas.96.2016.01.11.16.26.46
        for <linux-mm@kvack.org>;
        Mon, 11 Jan 2016 16:26:46 -0800 (PST)
Date: Mon, 11 Jan 2016 16:26:45 -0800
From: "Luck, Tony" <tony.luck@intel.com>
Subject: Re: [PATCH v8 3/3] x86, mce: Add __mcsafe_copy()
Message-ID: <20160112002645.GA10179@agluck-desk.sc.intel.com>
References: <cover.1452297867.git.tony.luck@intel.com>
 <19f6403f2b04d3448ed2ac958e656645d8b6e70c.1452297867.git.tony.luck@intel.com>
 <CALCETrVqn58pMkMc09vbtNdbU2VFtQ=W8APZ0EqtLCh3JGvxoA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrVqn58pMkMc09vbtNdbU2VFtQ=W8APZ0EqtLCh3JGvxoA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: linux-nvdimm <linux-nvdimm@ml01.01.org>, Dan Williams <dan.j.williams@intel.com>, Borislav Petkov <bp@alien8.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Robert <elliott@hpe.com>, Ingo Molnar <mingo@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, X86 ML <x86@kernel.org>

On Fri, Jan 08, 2016 at 05:49:30PM -0800, Andy Lutomirski wrote:
> Also, what's the sfence for?  You don't seem to be using any
> non-temporal operations.

So I deleted the "sfence" and now I just have a comment
at the 100: label.

37:
        shl $6,%ecx
        lea -48(%ecx,%edx),%edx
        jmp 100f
38:
        shl $6,%ecx
        lea -56(%ecx,%edx),%edx
        jmp 100f
39:
        lea (%rdx,%rcx,8),%rdx
        jmp 100f
40:
        mov %ecx,%edx
100:
        /* %rax set the fault number in fixup_exception() */
        ret

Should I just change all the "jmp 100f" into "ret"?  There
aren't any tools that will be confused that the function
has 10 returns, are there?

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
