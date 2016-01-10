Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f179.google.com (mail-yk0-f179.google.com [209.85.160.179])
	by kanga.kvack.org (Postfix) with ESMTP id D92A9828F3
	for <linux-mm@kvack.org>; Sat,  9 Jan 2016 19:23:54 -0500 (EST)
Received: by mail-yk0-f179.google.com with SMTP id x67so399392464ykd.2
        for <linux-mm@kvack.org>; Sat, 09 Jan 2016 16:23:54 -0800 (PST)
Received: from mail-yk0-x233.google.com (mail-yk0-x233.google.com. [2607:f8b0:4002:c07::233])
        by mx.google.com with ESMTPS id i63si65146641ywe.375.2016.01.09.16.23.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 09 Jan 2016 16:23:53 -0800 (PST)
Received: by mail-yk0-x233.google.com with SMTP id k129so376395627yke.0
        for <linux-mm@kvack.org>; Sat, 09 Jan 2016 16:23:53 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CALCETrVRgaWS86wq4B6oZbEY5_ODb3Nh5OeE9vvdGdds6j_pYg@mail.gmail.com>
References: <cover.1452297867.git.tony.luck@intel.com>
	<19f6403f2b04d3448ed2ac958e656645d8b6e70c.1452297867.git.tony.luck@intel.com>
	<CALCETrVqn58pMkMc09vbtNdbU2VFtQ=W8APZ0EqtLCh3JGvxoA@mail.gmail.com>
	<CA+8MBbL5Cwxjr_vtfE5n+XHPknFK4QMC3QNwaif5RvWo-eZATQ@mail.gmail.com>
	<CALCETrVQ_NxcnDr4N-VqROrMJ2hUzMKgmxjxAZu9TFbznqSDcg@mail.gmail.com>
	<CA+8MBbLUtVh3E4RqcHbZ165v+fURGYPm=ejOn2cOPq012BwLSg@mail.gmail.com>
	<CAPcyv4hAenpeqPsj7Rd0Un_SgDpm+CjqH3EK72ho-=zZFvG7wA@mail.gmail.com>
	<CALCETrVRgaWS86wq4B6oZbEY5_ODb3Nh5OeE9vvdGdds6j_pYg@mail.gmail.com>
Date: Sat, 9 Jan 2016 16:23:53 -0800
Message-ID: <CAPcyv4iCbp0oR_V+XCTduLd1t2UxyFwaoJVk0_vwk8aO2Uh=bQ@mail.gmail.com>
Subject: Re: [PATCH v8 3/3] x86, mce: Add __mcsafe_copy()
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Tony Luck <tony.luck@gmail.com>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Borislav Petkov <bp@alien8.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Robert <elliott@hpe.com>, Ingo Molnar <mingo@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, X86 ML <x86@kernel.org>

On Sat, Jan 9, 2016 at 2:33 PM, Andy Lutomirski <luto@amacapital.net> wrote:
> On Sat, Jan 9, 2016 at 2:15 PM, Dan Williams <dan.j.williams@intel.com> wrote:
>> On Sat, Jan 9, 2016 at 11:39 AM, Tony Luck <tony.luck@gmail.com> wrote:
>>> On Sat, Jan 9, 2016 at 9:57 AM, Andy Lutomirski <luto@amacapital.net> wrote:
>>>> On Sat, Jan 9, 2016 at 9:48 AM, Tony Luck <tony.luck@gmail.com> wrote:
>>>>> ERMS?
>>>>
>>>> It's the fast string extension, aka Enhanced REP MOV STOS.  On CPUs
>>>> with that feature (and not disabled via MSR), plain ol' rep movs is
>>>> the fastest way to copy bytes.  I think this includes all Intel CPUs
>>>> from SNB onwards.
>>>
>>> Ah ... very fast at copying .. but currently not machine check recoverable.
>>
>> Hmm, I assume for the pmem driver I'll want to check at runtime if the
>> cpu has machine check recovery and fall back to the faster copy if
>> it's not available?
>
> Shouldn't that logic live in the mcsafe_copy routine itself rather
> than being delegated to callers?
>

Yes, please.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
