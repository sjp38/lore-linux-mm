Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id EB904828F3
	for <linux-mm@kvack.org>; Sun, 10 Jan 2016 06:26:45 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id b14so229897337wmb.1
        for <linux-mm@kvack.org>; Sun, 10 Jan 2016 03:26:45 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id p126si14052446wmg.99.2016.01.10.03.26.44
        for <linux-mm@kvack.org>;
        Sun, 10 Jan 2016 03:26:44 -0800 (PST)
Date: Sun, 10 Jan 2016 12:26:35 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v8 3/3] x86, mce: Add __mcsafe_copy()
Message-ID: <20160110112635.GC22896@pd.tnic>
References: <cover.1452297867.git.tony.luck@intel.com>
 <19f6403f2b04d3448ed2ac958e656645d8b6e70c.1452297867.git.tony.luck@intel.com>
 <CALCETrVqn58pMkMc09vbtNdbU2VFtQ=W8APZ0EqtLCh3JGvxoA@mail.gmail.com>
 <CA+8MBbL5Cwxjr_vtfE5n+XHPknFK4QMC3QNwaif5RvWo-eZATQ@mail.gmail.com>
 <CALCETrVQ_NxcnDr4N-VqROrMJ2hUzMKgmxjxAZu9TFbznqSDcg@mail.gmail.com>
 <CA+8MBbLUtVh3E4RqcHbZ165v+fURGYPm=ejOn2cOPq012BwLSg@mail.gmail.com>
 <CAPcyv4hAenpeqPsj7Rd0Un_SgDpm+CjqH3EK72ho-=zZFvG7wA@mail.gmail.com>
 <CALCETrVRgaWS86wq4B6oZbEY5_ODb3Nh5OeE9vvdGdds6j_pYg@mail.gmail.com>
 <CAPcyv4iCbp0oR_V+XCTduLd1t2UxyFwaoJVk0_vwk8aO2Uh=bQ@mail.gmail.com>
 <CA+8MBbLFb1gdhFWeG-3V4=gHd-fHK_n1oJEFCrYiNa8Af6XAng@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CA+8MBbLFb1gdhFWeG-3V4=gHd-fHK_n1oJEFCrYiNa8Af6XAng@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@gmail.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-nvdimm <linux-nvdimm@ml01.01.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Robert <elliott@hpe.com>, Ingo Molnar <mingo@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, X86 ML <x86@kernel.org>

On Sat, Jan 09, 2016 at 05:40:05PM -0800, Tony Luck wrote:
> BUT ... it's all going to be very messy.  We don't have any CPUID
> capability bits to say whether we support recovery, or which instructions
> are good/bad choices for recovery.

We can always define synthetic ones and set them after having checked
MCA capability bits, f/m/s, etc., maybe even based on the list you're
supplying...

> Linux code recently got some recovery bits for AMD cpus ... I don't
> know what the story is on which models support this,

You mean this?

                /*
                 * overflow_recov is supported for F15h Models 00h-0fh
                 * even though we don't have a CPUID bit for it.
                 */
                if (c->x86 == 0x15 && c->x86_model <= 0xf)
                        mce_flags.overflow_recov = 1;

If so, that's just an improvement which makes MCi_STATUS[Overflow] MCEs
non-fatal.

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
