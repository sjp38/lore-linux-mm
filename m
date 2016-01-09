Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f42.google.com (mail-oi0-f42.google.com [209.85.218.42])
	by kanga.kvack.org (Postfix) with ESMTP id CB4C36B0256
	for <linux-mm@kvack.org>; Sat,  9 Jan 2016 12:57:45 -0500 (EST)
Received: by mail-oi0-f42.google.com with SMTP id o124so20932462oia.3
        for <linux-mm@kvack.org>; Sat, 09 Jan 2016 09:57:45 -0800 (PST)
Received: from mail-oi0-x236.google.com (mail-oi0-x236.google.com. [2607:f8b0:4003:c06::236])
        by mx.google.com with ESMTPS id o95si18836842oik.39.2016.01.09.09.57.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 09 Jan 2016 09:57:45 -0800 (PST)
Received: by mail-oi0-x236.google.com with SMTP id p187so12057494oia.2
        for <linux-mm@kvack.org>; Sat, 09 Jan 2016 09:57:45 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CA+8MBbL5Cwxjr_vtfE5n+XHPknFK4QMC3QNwaif5RvWo-eZATQ@mail.gmail.com>
References: <cover.1452297867.git.tony.luck@intel.com> <19f6403f2b04d3448ed2ac958e656645d8b6e70c.1452297867.git.tony.luck@intel.com>
 <CALCETrVqn58pMkMc09vbtNdbU2VFtQ=W8APZ0EqtLCh3JGvxoA@mail.gmail.com> <CA+8MBbL5Cwxjr_vtfE5n+XHPknFK4QMC3QNwaif5RvWo-eZATQ@mail.gmail.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Sat, 9 Jan 2016 09:57:25 -0800
Message-ID: <CALCETrVQ_NxcnDr4N-VqROrMJ2hUzMKgmxjxAZu9TFbznqSDcg@mail.gmail.com>
Subject: Re: [PATCH v8 3/3] x86, mce: Add __mcsafe_copy()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@gmail.com>
Cc: linux-nvdimm <linux-nvdimm@ml01.01.org>, Dan Williams <dan.j.williams@intel.com>, Borislav Petkov <bp@alien8.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Robert <elliott@hpe.com>, Ingo Molnar <mingo@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, X86 ML <x86@kernel.org>

On Sat, Jan 9, 2016 at 9:48 AM, Tony Luck <tony.luck@gmail.com> wrote:
> On Fri, Jan 8, 2016 at 5:49 PM, Andy Lutomirski <luto@amacapital.net> wrote:
>> On Jan 8, 2016 4:19 PM, "Tony Luck" <tony.luck@intel.com> wrote:
>>>
>>> Make use of the EXTABLE_FAULT exception table entries. This routine
>>> returns a structure to indicate the result of the copy:
>>
>> Perhaps this is silly, but could we make this feature depend on ERMS
>> and thus make the code a lot simpler?
>
> ERMS?

It's the fast string extension, aka Enhanced REP MOV STOS.  On CPUs
with that feature (and not disabled via MSR), plain ol' rep movs is
the fastest way to copy bytes.  I think this includes all Intel CPUs
from SNB onwards.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
