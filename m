Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6334C6B026A
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 11:34:24 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id j26so5081518pff.8
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 08:34:24 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 3si3077210pgi.649.2017.12.14.08.34.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Dec 2017 08:34:23 -0800 (PST)
Received: from mail-it0-f49.google.com (mail-it0-f49.google.com [209.85.214.49])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 1561C218A6
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 16:34:23 +0000 (UTC)
Received: by mail-it0-f49.google.com with SMTP id m11so25868220iti.1
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 08:34:23 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1712141731540.4998@nanos>
References: <20171214112726.742649793@infradead.org> <20171214113851.797295832@infradead.org>
 <CALCETrU5H_X6kfOxnsb1d92oUJHa-6kWm=BWANYD9JJgDD=YOA@mail.gmail.com>
 <alpine.DEB.2.20.1712141730410.4998@nanos> <alpine.DEB.2.20.1712141731540.4998@nanos>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 14 Dec 2017 08:34:00 -0800
Message-ID: <CALCETrXbFA2Pm5-9a8MCXJkm8hLW9fZuW7DxbdZJ-mCQ2Ozd8A@mail.gmail.com>
Subject: Re: [PATCH v2 14/17] x86/ldt: Reshuffle code
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, "Liguori, Anthony" <aliguori@amazon.com>, Will Deacon <will.deacon@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>

On Thu, Dec 14, 2017 at 8:32 AM, Thomas Gleixner <tglx@linutronix.de> wrote:
> On Thu, 14 Dec 2017, Thomas Gleixner wrote:
>
>>
>> On Thu, 14 Dec 2017, Andy Lutomirski wrote:
>>
>> > On Thu, Dec 14, 2017 at 3:27 AM, Peter Zijlstra <peterz@infradead.org> wrote:
>> > > From: Thomas Gleixner <tglx@linutronix.de>
>> > >
>> > > Restructure the code, so the following VMA changes do not create an
>> > > unreadable mess. No functional change.
>> >
>> > Can the PF_KTHREAD thing be its own patch so it can be reviewed on its own?
>>
>> I had that as a separate patch at some point.
>
> See 5/N

It looks like a little bit of it got mixed in to this patch, though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
