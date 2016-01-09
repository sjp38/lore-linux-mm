Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 6DF60828DE
	for <linux-mm@kvack.org>; Sat,  9 Jan 2016 12:48:04 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id f206so168272423wmf.0
        for <linux-mm@kvack.org>; Sat, 09 Jan 2016 09:48:04 -0800 (PST)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id o126si8101034wmb.73.2016.01.09.09.48.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 09 Jan 2016 09:48:03 -0800 (PST)
Received: by mail-wm0-x244.google.com with SMTP id f206so20297579wmf.2
        for <linux-mm@kvack.org>; Sat, 09 Jan 2016 09:48:03 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CALCETrVqn58pMkMc09vbtNdbU2VFtQ=W8APZ0EqtLCh3JGvxoA@mail.gmail.com>
References: <cover.1452297867.git.tony.luck@intel.com>
	<19f6403f2b04d3448ed2ac958e656645d8b6e70c.1452297867.git.tony.luck@intel.com>
	<CALCETrVqn58pMkMc09vbtNdbU2VFtQ=W8APZ0EqtLCh3JGvxoA@mail.gmail.com>
Date: Sat, 9 Jan 2016 09:48:02 -0800
Message-ID: <CA+8MBbL5Cwxjr_vtfE5n+XHPknFK4QMC3QNwaif5RvWo-eZATQ@mail.gmail.com>
Subject: Re: [PATCH v8 3/3] x86, mce: Add __mcsafe_copy()
From: Tony Luck <tony.luck@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: linux-nvdimm <linux-nvdimm@ml01.01.org>, Dan Williams <dan.j.williams@intel.com>, Borislav Petkov <bp@alien8.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Robert <elliott@hpe.com>, Ingo Molnar <mingo@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, X86 ML <x86@kernel.org>

On Fri, Jan 8, 2016 at 5:49 PM, Andy Lutomirski <luto@amacapital.net> wrote:
> On Jan 8, 2016 4:19 PM, "Tony Luck" <tony.luck@intel.com> wrote:
>>
>> Make use of the EXTABLE_FAULT exception table entries. This routine
>> returns a structure to indicate the result of the copy:
>
> Perhaps this is silly, but could we make this feature depend on ERMS
> and thus make the code a lot simpler?

ERMS?

> Also, what's the sfence for?  You don't seem to be using any
> non-temporal operations.

Ah - left over from the original function that this
was cloned from (which did use non-temporal
operations).  Will delete.

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
