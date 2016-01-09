Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 18AEB6B0256
	for <linux-mm@kvack.org>; Sat,  9 Jan 2016 14:39:16 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id l65so169637114wmf.1
        for <linux-mm@kvack.org>; Sat, 09 Jan 2016 11:39:16 -0800 (PST)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id jz10si184829555wjb.249.2016.01.09.11.39.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 09 Jan 2016 11:39:14 -0800 (PST)
Received: by mail-wm0-x244.google.com with SMTP id b14so20579272wmb.1
        for <linux-mm@kvack.org>; Sat, 09 Jan 2016 11:39:14 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CALCETrVQ_NxcnDr4N-VqROrMJ2hUzMKgmxjxAZu9TFbznqSDcg@mail.gmail.com>
References: <cover.1452297867.git.tony.luck@intel.com>
	<19f6403f2b04d3448ed2ac958e656645d8b6e70c.1452297867.git.tony.luck@intel.com>
	<CALCETrVqn58pMkMc09vbtNdbU2VFtQ=W8APZ0EqtLCh3JGvxoA@mail.gmail.com>
	<CA+8MBbL5Cwxjr_vtfE5n+XHPknFK4QMC3QNwaif5RvWo-eZATQ@mail.gmail.com>
	<CALCETrVQ_NxcnDr4N-VqROrMJ2hUzMKgmxjxAZu9TFbznqSDcg@mail.gmail.com>
Date: Sat, 9 Jan 2016 11:39:14 -0800
Message-ID: <CA+8MBbLUtVh3E4RqcHbZ165v+fURGYPm=ejOn2cOPq012BwLSg@mail.gmail.com>
Subject: Re: [PATCH v8 3/3] x86, mce: Add __mcsafe_copy()
From: Tony Luck <tony.luck@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: linux-nvdimm <linux-nvdimm@ml01.01.org>, Dan Williams <dan.j.williams@intel.com>, Borislav Petkov <bp@alien8.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Robert <elliott@hpe.com>, Ingo Molnar <mingo@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, X86 ML <x86@kernel.org>

On Sat, Jan 9, 2016 at 9:57 AM, Andy Lutomirski <luto@amacapital.net> wrote:
> On Sat, Jan 9, 2016 at 9:48 AM, Tony Luck <tony.luck@gmail.com> wrote:
>> ERMS?
>
> It's the fast string extension, aka Enhanced REP MOV STOS.  On CPUs
> with that feature (and not disabled via MSR), plain ol' rep movs is
> the fastest way to copy bytes.  I think this includes all Intel CPUs
> from SNB onwards.

Ah ... very fast at copying .. but currently not machine check recoverable.

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
