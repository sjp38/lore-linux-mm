Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 4CAFB828DF
	for <linux-mm@kvack.org>; Wed, 13 Jan 2016 23:40:12 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id f206so323866097wmf.0
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 20:40:12 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id mo12si6758750wjc.138.2016.01.13.20.40.10
        for <linux-mm@kvack.org>;
        Wed, 13 Jan 2016 20:40:10 -0800 (PST)
Date: Thu, 14 Jan 2016 05:39:56 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v8 3/3] x86, mce: Add __mcsafe_copy()
Message-ID: <20160114043956.GA8496@pd.tnic>
References: <CA+8MBbL5Cwxjr_vtfE5n+XHPknFK4QMC3QNwaif5RvWo-eZATQ@mail.gmail.com>
 <CALCETrVQ_NxcnDr4N-VqROrMJ2hUzMKgmxjxAZu9TFbznqSDcg@mail.gmail.com>
 <CA+8MBbLUtVh3E4RqcHbZ165v+fURGYPm=ejOn2cOPq012BwLSg@mail.gmail.com>
 <CAPcyv4hAenpeqPsj7Rd0Un_SgDpm+CjqH3EK72ho-=zZFvG7wA@mail.gmail.com>
 <CALCETrVRgaWS86wq4B6oZbEY5_ODb3Nh5OeE9vvdGdds6j_pYg@mail.gmail.com>
 <CAPcyv4iCbp0oR_V+XCTduLd1t2UxyFwaoJVk0_vwk8aO2Uh=bQ@mail.gmail.com>
 <CA+8MBbLFb1gdhFWeG-3V4=gHd-fHK_n1oJEFCrYiNa8Af6XAng@mail.gmail.com>
 <20160110112635.GC22896@pd.tnic>
 <20160111104425.GA29448@gmail.com>
 <CA+8MBbJpFWdkwC-yvmDFdFuLrchv2-XhPd3fk8A_hqOOyzm5og@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CA+8MBbJpFWdkwC-yvmDFdFuLrchv2-XhPd3fk8A_hqOOyzm5og@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@gmail.com>
Cc: Ingo Molnar <mingo@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-nvdimm <linux-nvdimm@ml01.01.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Robert <elliott@hpe.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, X86 ML <x86@kernel.org>

On Wed, Jan 13, 2016 at 03:22:58PM -0800, Tony Luck wrote:
> Are there some examples of synthetic CPUID bits?

X86_FEATURE_ALWAYS is one. The others got renamed into X86_BUG_* ones,
the remaining mechanism is the same, though.

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
