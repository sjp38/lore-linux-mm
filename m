Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 568906B0005
	for <linux-mm@kvack.org>; Mon,  4 Jan 2016 18:11:10 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id f206so4593606wmf.0
        for <linux-mm@kvack.org>; Mon, 04 Jan 2016 15:11:10 -0800 (PST)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id r62si1237229wmg.121.2016.01.04.15.11.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Jan 2016 15:11:09 -0800 (PST)
Received: by mail-wm0-x243.google.com with SMTP id l65so446750wmf.3
        for <linux-mm@kvack.org>; Mon, 04 Jan 2016 15:11:09 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CALCETrU9AN6HmButY0tV1F4syNHZVKyQyVvit2JHcHAuXK9XNA@mail.gmail.com>
References: <cover.1451869360.git.tony.luck@intel.com>
	<968b4c079271431292fddfa49ceacff576be6849.1451869360.git.tony.luck@intel.com>
	<20160104120751.GG22941@pd.tnic>
	<CA+8MBbKZ6VfN9t5-dYNHhZVU0k2HEr+E7Un0y2gtsxE0sDgoHQ@mail.gmail.com>
	<CALCETrU9AN6HmButY0tV1F4syNHZVKyQyVvit2JHcHAuXK9XNA@mail.gmail.com>
Date: Mon, 4 Jan 2016 15:11:08 -0800
Message-ID: <CA+8MBbKqZ-zbOGKK_jY2N1yz6hujWc1L-XbJBUKKxsfj9dyhUQ@mail.gmail.com>
Subject: Re: [PATCH v6 1/4] x86: Clean up extable entry format (and free up a bit)
From: Tony Luck <tony.luck@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Borislav Petkov <bp@alien8.de>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Robert <elliott@hpe.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86-ML <x86@kernel.org>

On Mon, Jan 4, 2016 at 10:08 AM, Andy Lutomirski <luto@amacapital.net> wrote:
> On Mon, Jan 4, 2016 at 9:26 AM, Tony Luck <tony.luck@gmail.com> wrote:
>> On Mon, Jan 4, 2016 at 4:07 AM, Borislav Petkov <bp@alien8.de> wrote:

>>> Why not simply:
>>>
>>>         .long (to) - . + (bias) ;
>>>
>>> and
>>>
>>>         " .long (" #to ") - . + "(" #bias ") "\n"
>>>
>>> below and get rid of that _EXPAND_EXTABLE_BIAS()?
>>
>> Andy - this part is your code and I'm not sure what the trick is here.
>
> I don't remember.  I think it was just some preprocessor crud to force
> all the macros to expand fully before the assembler sees it.  If it
> builds without it, feel free to delete it.

The trick is definitely needed in the case of

# define _EXPAND_EXTABLE_BIAS(x) #x

Trying to expand it inline and get rid of the macro led to
horrible failure. The __ASSEMBLY__ case where the
macro does nothing isn't required ... but does provide
a certain amount of symmetry when looking at the two
versions of _ASM_EXTABLE_CLASS

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
