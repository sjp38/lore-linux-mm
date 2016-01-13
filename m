Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 8842E828DF
	for <linux-mm@kvack.org>; Wed, 13 Jan 2016 18:23:00 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id f206so396287688wmf.0
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 15:23:00 -0800 (PST)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id jn10si5388204wjb.31.2016.01.13.15.22.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jan 2016 15:22:59 -0800 (PST)
Received: by mail-wm0-x243.google.com with SMTP id b14so39527361wmb.1
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 15:22:59 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160111104425.GA29448@gmail.com>
References: <19f6403f2b04d3448ed2ac958e656645d8b6e70c.1452297867.git.tony.luck@intel.com>
	<CALCETrVqn58pMkMc09vbtNdbU2VFtQ=W8APZ0EqtLCh3JGvxoA@mail.gmail.com>
	<CA+8MBbL5Cwxjr_vtfE5n+XHPknFK4QMC3QNwaif5RvWo-eZATQ@mail.gmail.com>
	<CALCETrVQ_NxcnDr4N-VqROrMJ2hUzMKgmxjxAZu9TFbznqSDcg@mail.gmail.com>
	<CA+8MBbLUtVh3E4RqcHbZ165v+fURGYPm=ejOn2cOPq012BwLSg@mail.gmail.com>
	<CAPcyv4hAenpeqPsj7Rd0Un_SgDpm+CjqH3EK72ho-=zZFvG7wA@mail.gmail.com>
	<CALCETrVRgaWS86wq4B6oZbEY5_ODb3Nh5OeE9vvdGdds6j_pYg@mail.gmail.com>
	<CAPcyv4iCbp0oR_V+XCTduLd1t2UxyFwaoJVk0_vwk8aO2Uh=bQ@mail.gmail.com>
	<CA+8MBbLFb1gdhFWeG-3V4=gHd-fHK_n1oJEFCrYiNa8Af6XAng@mail.gmail.com>
	<20160110112635.GC22896@pd.tnic>
	<20160111104425.GA29448@gmail.com>
Date: Wed, 13 Jan 2016 15:22:58 -0800
Message-ID: <CA+8MBbJpFWdkwC-yvmDFdFuLrchv2-XhPd3fk8A_hqOOyzm5og@mail.gmail.com>
Subject: Re: [PATCH v8 3/3] x86, mce: Add __mcsafe_copy()
From: Tony Luck <tony.luck@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Borislav Petkov <bp@alien8.de>, Dan Williams <dan.j.williams@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-nvdimm <linux-nvdimm@ml01.01.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Robert <elliott@hpe.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, X86 ML <x86@kernel.org>

On Mon, Jan 11, 2016 at 2:44 AM, Ingo Molnar <mingo@kernel.org> wrote:
> So such a synthetic CPUID bit would definitely be useful.
>
> Also, knowing whether a memcpy function is recoverable or not, should not be
> delegated to callers: there should be the regular memcpy APIs, plus new APIs that
> do everything they can to provide recoverable memory copies. Whether it's achieved
> via flag checking, a function pointer or code patching is an implementation detail
> that's not visible to drivers making use of the new facility.
>
> I'd go for the simplest, most robust solution initially, also perhaps with boot
> time messages to make sure users know which variant is used and now.

Are there some examples of synthetic CPUID bits?  I grepped around and
found a handful of places making ad hoc decisions based on sub-strings of
x86_model_id[] ... but didn't find any systematic approach.

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
