Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f172.google.com (mail-io0-f172.google.com [209.85.223.172])
	by kanga.kvack.org (Postfix) with ESMTP id 3BFF282F64
	for <linux-mm@kvack.org>; Tue,  3 Nov 2015 18:18:48 -0500 (EST)
Received: by iodd200 with SMTP id d200so36148695iod.0
        for <linux-mm@kvack.org>; Tue, 03 Nov 2015 15:18:48 -0800 (PST)
Received: from mail-ig0-x234.google.com (mail-ig0-x234.google.com. [2607:f8b0:4001:c05::234])
        by mx.google.com with ESMTPS id cj8si17247306igb.49.2015.11.03.15.18.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Nov 2015 15:18:47 -0800 (PST)
Received: by igpw7 with SMTP id w7so92209283igp.0
        for <linux-mm@kvack.org>; Tue, 03 Nov 2015 15:18:47 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151103223904.GG8644@n2100.arm.linux.org.uk>
References: <1446574204-15567-1-git-send-email-dcashman@android.com>
	<1446574204-15567-2-git-send-email-dcashman@android.com>
	<CAGXu5jKGzDD9WVQnMTT2EfupZtjpdcASUpx-3npLAB-FctLodA@mail.gmail.com>
	<20151103223904.GG8644@n2100.arm.linux.org.uk>
Date: Tue, 3 Nov 2015 15:18:47 -0800
Message-ID: <CAGXu5jJWdZ57uMACwRBcOoU8MqPu9-pN+cp9WzyguY+G3C5qWg@mail.gmail.com>
Subject: Re: [PATCH v2 2/2] arm: mm: support ARCH_MMAP_RND_BITS.
From: Kees Cook <keescook@chromium.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Daniel Cashman <dcashman@android.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Jonathan Corbet <corbet@lwn.net>, Don Zickus <dzickus@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Heinrich Schuchardt <xypron.glpk@gmx.de>, jpoimboe@redhat.com, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, n-horiguchi@ah.jp.nec.com, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Thomas Gleixner <tglx@linutronix.de>, David Rientjes <rientjes@google.com>, Linux-MM <linux-mm@kvack.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Mark Salyzyn <salyzyn@android.com>, Jeffrey Vander Stoep <jeffv@google.com>, Nick Kralevich <nnk@google.com>, dcashman <dcashman@google.com>

On Tue, Nov 3, 2015 at 2:39 PM, Russell King - ARM Linux
<linux@arm.linux.org.uk> wrote:
> On Tue, Nov 03, 2015 at 11:19:44AM -0800, Kees Cook wrote:
>> On Tue, Nov 3, 2015 at 10:10 AM, Daniel Cashman <dcashman@android.com> wrote:
>> > From: dcashman <dcashman@google.com>
>> >
>> > arm: arch_mmap_rnd() uses a hard-code value of 8 to generate the
>> > random offset for the mmap base address.  This value represents a
>> > compromise between increased ASLR effectiveness and avoiding
>> > address-space fragmentation. Replace it with a Kconfig option, which
>> > is sensibly bounded, so that platform developers may choose where to
>> > place this compromise. Keep 8 as the minimum acceptable value.
>> >
>> > Signed-off-by: Daniel Cashman <dcashman@google.com>
>>
>> Acked-by: Kees Cook <keescook@chromium.org>
>>
>> Russell, if you don't see any problems here, it might make sense not
>> to put this through the ARM patch tracker since it depends on the 1/2,
>> and I think x86 and arm64 (and possibly other arch) changes are coming
>> too.
>
> Yes, it looks sane, though I do wonder whether there should also be
> a Kconfig option to allow archtectures to specify the default, instead
> of the default always being the minimum randomisation.  I can see scope
> to safely pushing our mmap randomness default to 12, especially on 3GB
> setups, as we already have 11 bits of randomness on the sigpage and if
> enabled, 13 bits on the heap.

My thinking is that the there shouldn't be a reason to ever have a
minimum that was below the default. I have no objection with it, but
it seems needless. Frankly minimum is "0", really, so I don't think it
makes much sense to have default != arch minimum. I actually view
"arch minimum" as "known good", so if we are happy with raising the
"known good" value, that should be the new minimum.

-Kees

-- 
Kees Cook
Chrome OS Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
